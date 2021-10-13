classdef (Hidden) ComponentLoadingProxyViewFactory < matlab.ui.control.internal.view.ComponentProxyViewFactory
    % ComponentLoadingProxyViewFactory
    %
    % Responsible for attaching loaded design-time properties to component
    % Proxy Views.
    %
    % Usage:
    %
    % - created with meta data pertaining to the next App Window to load
    %
    % - should be installed as the ComponentProxyViewFactoryManager before
    %   initiating component loading
    %
    % - as components are loaded and Proxy Views are created, this class
    %   intercepts the creation request and appends design-time properties
    
    
    %   Copyright 2013-2015 The MathWorks, Inc.
    
    properties
        % an array of structs, where each struct contains information for
        % each component in the App
        % Each struct contains two fields:
        %  1.  Type - component type
        %  2.  PropertyValues - a struct of pv pairs, including design time
        %                       data
        ComponentData = struct.empty;
    end
    
    properties(Access=private)
        % file name of the App
        FileName
        
        % a map of structures containing component information, where the
        % keys in the map are the serialization ids of the components
        ComponentDataMap
        
        % codeModel associated with the App
        CodeModel
    end
    
    methods
        function obj = ComponentLoadingProxyViewFactory()
            % Constructor
            
            obj.ComponentDataMap = containers.Map;
        end
        
        function proxyView = createProxyView(obj, type, parentController, propertyNameValues)
            % convert the propertyNameValues to a struct
            values = appdesservices.internal.peermodel.convertPvPairsToStruct(propertyNameValues);
            
            % create a data structure of following fileds to hold component info
            %    Type - component type
            %    PropertyValues - a struct of pv pairs
            %    Children - an array of structs just like this, where each
            %               struct in the array is a child of the component
            componentData = struct;
            componentData.Type = type;
            componentData.PropertyValues = values;
            componentData.Children =...
                struct('Type',{}, 'PropertyValues',{}, 'Children',{});
            
            % add the component data struct to the map to be used later
            % when the data is converted to a hierarchyof structures, where
            % the componentData.Children
            obj.ComponentDataMap(values.DesignTimeProperties.CodeName) = componentData;
            
            % set the proxyView to be empty so no actual view is created
            proxyView = [];
        end
        
        function [componentAndGroupData, codeDataStructure, serializedAppName] = getComponentData(obj,fileName)
            % return the component data in the App of 'fileName'
            
            try
                % create a FileReader object
                fileReader = ...
                    appdesigner.internal.serialization.FileReader(fileName);
                
                % Load data from the App file
                appData = readAppDesignerData(fileReader);
                
                % extract the specific serialized objects
                appWindow = appData.UIFigure;
                codeData = appData.CodeData;
                groupHierarchy = appData.Metadata.GroupHierarchy;
                
                % Delete loaded window object after loading
                c = onCleanup(@()delete(appWindow));
            catch me
                % Rethrow the exception because FileReader provides appropriate error messages
                rethrow(me);
            end
            
            try
                % determine if its a 16a app or not
                isR16aApp = strcmp(appData.ToolboxVer, '2016a');
                if ~isR16aApp
                   obj.launchForwardCompatibilityDialog();
                end
          
                % call the initializeForLoad() method on the appwindow so its
                % properties and children's properties can be collected.
                % When this method is called the createProxyView() method above
                % is invoked on the appWindow and all its children, and the
                % ComponentDataMap filled with properties for all components
                % that will be sent to the client
                obj.initializeForLoad(appWindow);
                
                % walk the appWindow hierarchy to create a hierarchical
                % structure of structures
                componentData = obj.buildComponentHierarchy(appWindow);
                
                % create the component and group data structure. This is the first return arg
                % of this method
                componentAndGroupData = struct;
                componentAndGroupData.ComponentData = componentData;
                componentAndGroupData.GroupData = groupHierarchy;
                
                % convert the serialized codeModel data to a structure understood
                % by the client.  This is the second return arg of this method
                codeDataStructure = obj.convertCodelModelDataForLoad(codeData);
                
                % get the serialized AppName.  This is the third return arg of
                % this method
                serializedAppName = codeData.GeneratedClassName;
                
            catch me
                % Throw generic error message since any failure messages
                % not provide value to the user.
                [~, name, ext] = fileparts(fileName);
                error(message('MATLAB:appdesigner:appdesigner:LoadFailed', [name, ext]));
            end
        end
            
        % recursively walk the children to build a structure of structures
        function data = buildComponentHierarchy(obj, parentComponent)
            
            codeName = ...
                parentComponent.DesignTimeProperties.CodeName;
            data = obj.ComponentDataMap(codeName);
            
            % Handle design time properties:
            % Add the design time properties from the DesignTimeProperties
            % object of the model to the list of properties going to the
            % client for creating components.
            % In this way the client will treat these properties as any other.
            % ALso need to remove the DesignTimeProperties property from
            % the list of properties going to the client
            designTimeProperty = data.PropertyValues.DesignTimeProperties;
            data.PropertyValues = rmfield(data.PropertyValues, 'DesignTimeProperties');
            for idx = 1:length(appdesigner.internal.model.DesignTimeProperties.ProperyNamesForView)
                fieldName = appdesigner.internal.model.DesignTimeProperties.ProperyNamesForView{idx};
                data.PropertyValues.(fieldName) = designTimeProperty.(fieldName);
            end
            
            metaClass = metaclass(parentComponent);
            hasChildrenProperty = any(strcmp('Children', {metaClass.PropertyList.Name}));
            if ( hasChildrenProperty && ~isa( parentComponent, 'matlab.ui.control.UIAxes'))
                children = parentComponent.Children;
                order = 1:length(children);
                % reestablish the children in reverse order becuase HG
                % order is last created component is first child.
                % The order for TabGroup is not reversed
                if (~isa(parentComponent, 'matlab.ui.container.TabGroup') && ~appdesservices.internal.component.model.isVisualComponent(parentComponent))
                    order = flip(order);
                end
                
                for i = order
                    component = children(i);
                    data.Children(end+1) = obj.buildComponentHierarchy(component);
                end
            end
        end
        
        function dataForLoad = convertCodelModelDataForLoad(obj,codeModel)
            % convert the serialized CodeModelData to an array of structures, a format required by
            % the client.  
           
            % get the editable section object of the code model
            editableSectionObj = codeModel.EditableSection;

             % create editableSection struct
            editableSection = struct;
            editableSection.Type = editableSectionObj.Type;
            editableSection.Children = struct.empty;
            editableSection.PropertyValues.Name = editableSectionObj.Type;
            editableSection.PropertyValues.BodyText = editableSectionObj.Code;
            editableSection.PropertyValues.Exist = editableSectionObj.Exist;
            
            % creat the callbacks struct
            callbackMethodsBlock = struct;
            callbackMethodsBlock.Type = 'CallbackMethodsBlock';
            callbackMethodsBlock.PropertyValues = [];
            
            % get the startupFcn object of the code model
            startupFcn = codeModel.StartupFcn;
            
            % add the startup function as the first child in the callbackMethodsBlock struct
            callbackMethodsBlock.Children(1).Type = startupFcn.Type;
            callbackMethodsBlock.Children(1).Children = struct.empty;
            
            callbackMethodsBlock.Children(1).PropertyValues.Name = startupFcn.Name;
           
            callbackMethodsBlock.Children(1).PropertyValues.OuterComment = startupFcn.Comment;
            callbackMethodsBlock.Children(1).PropertyValues.InputArguments = startupFcn.Args;
            callbackMethodsBlock.Children(1).PropertyValues.OutputArguments = startupFcn.ReturnArgs;
            callbackMethodsBlock.Children(1).PropertyValues.OuterComment = startupFcn.Comment;
            callbackMethodsBlock.Children(1).PropertyValues.BodyText = startupFcn.Code;
            
            % these fields are required for 16a code gen to be sent to the
            % client.  
            callbackMethodsBlock.Children(1).PropertyValues.IsWritable = true;
            callbackMethodsBlock.Children(1).PropertyValues.Access = 'private';
            callbackMethodsBlock.Children(1).PropertyValues.BodyDescription = 'writableline';
            
                              
            % get the callbacks array from the serialized CodeModel
             callbacks = codeModel.Callbacks;
             
             % loop over the callbacks and add as children of the callbackMethodsBlock struct
             for i = 1:numel(callbacks)
                 cb = callbacks(i);
                 
                 % callbacks start in the second position of  the
                 % callbackMethodsBlock Children
                 index = i+1;
                 callbackMethodsBlock.Children(index).Type = cb.Type;
                 callbackMethodsBlock.Children(index).Children = struct.empty;
                 callbackMethodsBlock.Children(index).PropertyValues.Name = cb.Name;
                 callbackMethodsBlock.Children(index).PropertyValues.OuterComment = cb.Comment;
                 callbackMethodsBlock.Children(index).PropertyValues.InputArguments = cb.Args;
                 callbackMethodsBlock.Children(index).PropertyValues.OutputArguments = cb.ReturnArgs;
                 callbackMethodsBlock.Children(index).PropertyValues.OuterComment = cb.Comment;
                 callbackMethodsBlock.Children(index).PropertyValues.BodyText = cb.Code;
                 
                 % these fields are required for 16a code gen to be sent to the
                 % client.
                 callbackMethodsBlock.Children(index).PropertyValues.IsWritable = true;
                 callbackMethodsBlock.Children(index).PropertyValues.Access = 'private';
                 callbackMethodsBlock.Children(index).PropertyValues.BodyDescription = 'writableLine';
                 
                 % if the callback's ComponentData object is not empty then set the callback's componentInfo  structure
                 % if it is empty then it must be an orphan callback so no ComponentInfo
                 if ( ~isempty(cb.ComponentData))                 
                     callbackMethodsBlock.Children(index).PropertyValues.ComponentInfo.CallbackPropertyName = ...
                         cb.ComponentData.CallbackPropertyName;
                     callbackMethodsBlock.Children(index).PropertyValues.ComponentInfo.CodeName = ...
                         cb.ComponentData.CodeName;
                     callbackMethodsBlock.Children(index).PropertyValues.ComponentInfo.ComponentType = ...
                         cb.ComponentData.ComponentType;
                 end              
             end
            
              dataForLoad = struct.empty;
              dataForLoad = editableSection;
              dataForLoad(2) = callbackMethodsBlock;
        end
        
    end
    
    methods (Access = private)
              
        function initializeForLoad(obj, appWindow)
            % Ensure the properties of the AppWindow and all its children can
            % be collected as part of opening an App. This involves creating
            % the controllers for all components which causes the
            % properties and their values to be collected
            
            parentController = [];
            
            designTimeAppWindow = appWindow;
            if (isa(appWindow, 'matlab.ui.Figure'))           
                % A GBT figure has been serialized, and then need to create
                % a design time AppWindow for loading
                designTimeAppWindow = matlab.ui.control.AppWindow();
                
                % Apply properties to AppWindow
                propertyNames = matlab.ui.control.AppWindow.getPropertyNamesForSerialization();
                for ix = 1:numel(propertyNames)
                    % If property not exist, it's a dynamic property and
                    % add it to AppWindow
                    if ~isprop(designTimeAppWindow, propertyNames{ix})
                        addprop(designTimeAppWindow, propertyNames{ix});
                    end
                    
                    if (strcmp(propertyNames{ix}, 'CloseRequestFcn') && ...
                            strcmp(appWindow.CloseRequestFcn, 'closereq'))
                        % It's a default value from the GBT figure, and for
                        % AppWindow it should be empty string
                        designTimeAppWindow.(propertyNames{ix}) = '';
                        
                    elseif strcmp(propertyNames{ix}, 'InnerPosition')
                        % the design-time AppWindow requires the InnerPosition property. Since the 16a
                        % UIFigure doesn't have this property, it was added as a dynamic property to the UIFigure.
                    	% However, starting in 16b the InnerPostion property was added as a real
                        % property on the UIFigure.  What this caused is that any 16b+ apps loaded in 
                        % 16a App Designer would not have this property because its not in the 16a
                        % class definition of the UIFigure.  
                    	% So after loading from the app file, the InnerPosition property would not exist, 
                        % causing an error on load.  It turns out the  InnerPosition has the same value 
                    	% with the Position property, so set the design-time AppWindow's InnerPosition
                        % property to the Position.  This solves the error
                        designTimeAppWindow.(propertyNames{ix}) = appWindow.Position;
                        
                    elseif strcmp(propertyNames{ix}, 'AutoResize')
                        % the design-time AppWindow requires the AutoResize property. 
                        % The AutoResize property was added as a dynamic property on the UIFigure in 16a and 16b,
                        % but no longer in 17a.  So if the UIFigure has the AutoResize property (a 16a or 16b app), 
                        % set the AppWindow's  AutoResize property to its value.
                        if isprop(appWindow, 'AutoResize')
                            designTimeAppWindow.AutoResize = appWindow.AutoResize;
                        end
                        %  If the UIFigure doesn't have the AutoResize property (17a apps and beyond), the AppWindow's 
                        % AutoResize property is the default value, which is true.
                        
                    else
                        designTimeAppWindow.(propertyNames{ix}) = appWindow.(propertyNames{ix});
                    end
                end
            end
            
            % Create the controller for the AppWindow
            controller = designTimeAppWindow.createController(parentController);
            
            % Walk the children and have them partake in loading of the app
            for idx = 1:length(appWindow.Children)
                childComponent = appWindow.Children(idx);
                if( ~appdesservices.internal.component.model.isVisualComponent(childComponent))
                    % hg components need to have some special logic to
                    % partake in the ComponentLoadingFactory
                    obj.processHgComponent(childComponent, controller)
                else
                    % it's a Visual component so have it create its
                    % controller which will end up causing its properties
                    % to be collected by the ComponentLoadingFactory
                    childComponent.createController(controller, []);
                end
            end
        end
        
        function processHgComponent(obj, component, parentController)
            % hg components need to partake in the ComponentLoadingFactory
            % by creating their controller and calling the
            % createProxyView() method on the ComponentLoadingFactory
            proxyView = [];
            if ( isa( component, 'matlab.ui.container.TabGroup' ) )
                controller = matlab.ui.internal.DesignTimeTabGroupController( component, ...
                    parentController, proxyView );
            elseif ( isa( component, 'matlab.ui.container.Tab' ) )
                controller = matlab.ui.internal.DesignTimeTabController( component, ...
                    parentController, proxyView );
            elseif ( isa( component, 'matlab.ui.container.ButtonGroup' ) )
                controller = matlab.ui.internal.DesignTimeButtonGroupController( component, ...
                    parentController, proxyView );
            elseif ( isa( component, 'matlab.ui.container.Panel' ) )
                controller = matlab.ui.internal.DesignTimePanelController( component, ...
                    parentController, proxyView );
            elseif ( isa( component, 'matlab.ui.control.Table' ) )
                controller = matlab.ui.internal.DesignTimeTableController( component, ...
                    parentController, proxyView );
            elseif ( isa( component, 'matlab.ui.control.UIAxes' ) )
                controller = appdesigner.internal.componentcontroller.DesignTimeUIAxesController( component, ...
                    parentController, proxyView );
            else
                assert(false,'Unsupported HG component type in loading an app');
            end
            
            factoryManager = matlab.ui.control.internal.view.ComponentProxyViewFactoryManager.Instance;
            componentLoadingFactory = factoryManager.ProxyViewFactory;
            
            % In 16a, HG components had a SerializationID property set as a dynamic property and was required for load.
            % In 16b however, this property was no longer added as a dynamic property becuase it really wasn't even used for
            % anything.  So simply check if there is a SerializationID property on the component.  If there isn't one, just add one.
            %  The value doesn't matter because its not used even though its required on load.
            if ~isprop(component, 'SerializationID')
                % If there is no SerializationID, just add one and set a value
                sIdProp = addprop(component, 'SerializationID');
                sIdProp.Transient = true;
                component.SerializationID = 'SerializationId_Placeholder';
            end
            
            pvPairs = controller.restoreFromModel();
            % Append DesingTimeProperties to hg component, so all
            % the hg controllers do not have to do that
            pvPairs = [pvPairs, {'DesignTimeProperties', component.DesignTimeProperties}];
            componentLoadingFactory.createProxyView(class(component), ...
                parentController, ...
                pvPairs);
            
            % loop over the components children and have them be processes
            % accordingly
            if(~isa( component, 'matlab.ui.control.UIAxes' ))
                for idy = 1:length(component.Children)
                    child  = component.Children(idy);
                    if (~appdesservices.internal.component.model.isVisualComponent(child))
                        obj.processHgComponent(child, controller);
                    else
                        child.createController(controller, proxyView);
                    end
                end
            end
        end
        
        function launchForwardCompatibilityDialog(obj)
            
            % get the html for the forward compatibility dialog
            relativeURL = 'toolbox/matlab/uicomponents/uicomponents/+matlab/+ui/+control/+internal/+view/forwardCompatibilityDialog16a.html';
            
            % get the dialog URL
            dialogURL = connector.getUrl(relativeURL);
            
            % get the list of cef windows
            webWindowList =  matlab.internal.webwindowmanager.instance.windowList;
            
            % find the cef window that is App Designer.  Do this by finding the substring in the URL of the cef window list that is
            % unique to App Designer
            uniqueAppDesignerString = 'toolbox/matlab/appdesigner/web/index.html';
            for i=1:length(webWindowList)
                webwindow = webWindowList(i);
                url = webwindow.URL;
                if ( strfind(url,uniqueAppDesignerString)>0 )
                    appDesigner = webwindow;
                end
            end
            
            % get App Designer's position
            appDesignerPosition = appDesigner.Position;
            
            % set the  width and height of the dialog and determine its x,y position relative to App Designer's position
            dialogWidth = 425;
            dialogHeight = 130;
            dialogX = appDesignerPosition(1) + floor(appDesignerPosition(3) / 2) - floor(dialogWidth / 2);
            dialogY = appDesignerPosition(2) + floor(appDesignerPosition(4) / 2) - floor(dialogHeight / 2);
            
            % create the web window and set its Position
            ww = matlab.internal.webwindow(dialogURL);
            ww.Position = [dialogX dialogY dialogWidth dialogHeight];
            
            % set some properties and show it
            ww.setResizable(false);
            ww.setAlwaysOnTop(true);
            ww.show();
        end
       
    end
end
