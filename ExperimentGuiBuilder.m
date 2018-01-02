classdef ExperimentGuiBuilder < handle
    properties (Access= public, Constant)
        ENUM_VERIFY_POSITIVE_INTEGER= 1;
        ENUM_VERIFY_NON_NEGATIVE_INTEGER= 2;
        ENUM_VERIFY_REAL= 3;
        ENUM_VERIFY_POSITIVE_REAL= 4;
        ENUM_VERIFY_NON_NEGATIVE_REAL= 5;
                        
        ENUM_EYE_TRACKING_EYE_TRACKER= 1;
        ENUM_EYE_TRACKING_DUMMY_MODE= 2;
        ENUM_EYE_TRACKING_NO_TRACKING= 3;                
        
        ENUM_LAB1= 1;
        ENUM_LAB2= 2;
        ENUM_LAB3= 3;
        
        KEY_CODES_ESC= 27;
    end        
    
    properties (Access=private, Constant)
        VARIABLE_VERIFIERS= {@ExperimentGuiBuilder.isStrAValidPositiveInteger, ...
                             @ExperimentGuiBuilder.isStrAValidNonNegativeInteger, ...
                             @ExperimentGuiBuilder.isStrAValidReal, ...
                             @ExperimentGuiBuilder.isStrAValidPositiveReal, ...
                             @ExperimentGuiBuilder.isStrAValidNonNegativeReal};
        FIGURE_POS= [0.1, 0.1, 0.8, 0.8];        
        DEFAULT_GUI_XML_FILE_PATH= 'guiXML.xml';
        LABS_CONSTS_XML_FILE_PATH= 'labConsts.xml';
        XML_DOC_LMNT_NAME= 'GUI_UICONTROLS_DATA';
        XML_COMMON_UICONTROLS_NODE_NAME= 'COMMON_UICONTROLS';
        XML_CURR_EXP_UICONTROLS_NODE_NAME= 'CURR_EXP_UICONTROLS';
        VALUE_TAG = 'VALUE';
        POS_TAG = 'POSITION';
        EXTRA_DATA_TAG = 'EXTRA_DATA';
        XML_NODES_NAMES_PREFIX= 'c';
        DEFAULT_CURR_EXP_UICONTROL_POS=[0.1000    0.5000	0.2165    0.0485];
        DEFAULT_COMMON_UICONTROLS_POS= [0.7688    0.8983    0.2000    0.0877;             
                                        0.0237    0.9409    0.2165    0.0485;                                            
                                        0.0237    0.8936    0.2165    0.0485;
                                        0.4308    0.8983    0.1900    0.0877;                                                                                                                    
                                        0.0507    0.8223    0.2165    0.0485;
                                        0.3971    0.8223    0.2165    0.0485;                                
                                        0.4992    0.2600    0.2165    0.0485;
                                        0.7410    0.2600    0.2165    0.0485;
                                        0.8173    0.1926    0.1709    0.0267;
                                        0.5923    0.1259    0.2165    0.0485;
                                        0.5923    0.1746    0.2165    0.0485;
                                        0.0237    0.1294    0.2228    0.0885;
                                        0.2619    0.1880    0.0525    0.0277;
                                        0.0427    0.7131    0.1968    0.0532;
                                        0.0214    0.0702    0.0778    0.0356];          
                
        ENUM_UICONTROLS_CREATOR_GUI_BUILDER= 1;
        ENUM_UICONTROLS_CREATOR_USER= 2;                
    end     
    
    properties (Access= private)            
        background_color= [];       
        xml_file_path= fullfile(ExperimentGuiBuilder.DEFAULT_GUI_XML_FILE_PATH);
        xml_dom= [];                
        lab_consts_xml_path= fullfile(ExperimentGuiBuilder.LABS_CONSTS_XML_FILE_PATH);
        lab_consts_xml_dom= [];
        common_uicontrols_xml_node= [];
        curr_exp_uicontrols_xml_node= [];
        fig= [];
        run_exp_func= [];
        common_uicontrols= [];             
        curr_exp_uicontrols= [];
        custom_uicontrols= [];
        uicontrols_creator= ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER;
        xml_file_creator= [];
        load_file_icon = []; 
        current_folder_load_file = [];
    end
               
    methods (Access= public)        
        function obj= ExperimentGuiBuilder(exp_name, background_color, run_exp_func, gui_xml_file_path)                        
            if nargin==4
                obj.xml_file_path= gui_xml_file_path;                       
            end
            
            if exist(obj.xml_file_path, 'file')==2
                obj.xml_dom= xmlread(obj.xml_file_path); 
                obj.common_uicontrols_xml_node= obj.xml_dom.getElementsByTagName(obj.XML_COMMON_UICONTROLS_NODE_NAME).item(0);
                obj.curr_exp_uicontrols_xml_node=obj.xml_dom.getElementsByTagName(obj.XML_CURR_EXP_UICONTROLS_NODE_NAME).item(0);
                if isempty(obj.common_uicontrols_xml_node) || isempty(obj.curr_exp_uicontrols_xml_node)
                    error('invalid gui xml file');                    
                end
                
                obj.xml_file_creator= ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER;
            else
                obj.xml_dom= com.mathworks.xml.XMLUtils.createDocument(obj.XML_DOC_LMNT_NAME);
                obj.common_uicontrols_xml_node= obj.xml_dom.createElement(obj.XML_COMMON_UICONTROLS_NODE_NAME);
                obj.xml_dom.getDocumentElement.appendChild(obj.common_uicontrols_xml_node);
                obj.curr_exp_uicontrols_xml_node= obj.xml_dom.createElement(obj.XML_CURR_EXP_UICONTROLS_NODE_NAME);
                obj.xml_dom.getDocumentElement.appendChild(obj.curr_exp_uicontrols_xml_node);
                obj.xml_file_creator= ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER;
            end
            
            obj.background_color= background_color;
            obj.lab_consts_xml_dom= xmlread(obj.lab_consts_xml_path);
            
            load_file_img = imread('resources/Folder-Explorer-icon.png','png');
            obj.load_file_icon= imresize(load_file_img, 0.2);
            obj.current_folder_load_file = pwd;
            
            obj.common_uicontrols.is= []; 
            obj.common_uicontrols.values= {};    
            obj.common_uicontrols.handles= [];    
            obj.curr_exp_uicontrols.is= []; 
            obj.curr_exp_uicontrols.values= {};   
            obj.curr_exp_uicontrols.handles= [];
            obj.curr_exp_uicontrols.on_exp_end_value_updaters= {}; 
            obj.custom_uicontrols.is= []; 
            obj.custom_uicontrols.get_value_funcs= [];
            obj.custom_uicontrols.set_value_funcs= [];
            obj.custom_uicontrols.handles= [];  
            obj.custom_uicontrols.on_exp_end_value_updaters= {};
            
            obj.fig= figure('Visible', 'off', 'units', 'normalized', ...
                'name', exp_name, 'NumberTitle', 'off', ...
                'Position', ExperimentGuiBuilder.FIGURE_POS, ...
                'MenuBar', 'none', ...
                'color', obj.background_color, ...
                'userdata', pwd);
            
            menu_bar= uimenu(obj.fig, 'Label', 'Action');            
            uimenu(menu_bar,'Label', 'Edit Plot', 'callback', @editUIControlsPosCallback);
            uimenu(menu_bar,'Label', 'Save Positions', 'callback', @saveUIControlsPos);
            
            %subject's number, age, gender
            uipanel('tag', 'p1', 'units', 'normalized', ...
                'Position',[0.0152    0.8889    0.9802    0.1055], ...
                'Background', obj.background_color);
            
            obj.uicontrolRadios(1, 'Experiment Room', {ExperimentGuiBuilder.ENUM_LAB1, ExperimentGuiBuilder.ENUM_LAB2, ExperimentGuiBuilder.ENUM_LAB3}, {'shlomit 1', 'shlomit 2', 'dominique'});
            obj.uicontrolReadNum(2, 'Subject`s Number', ExperimentGuiBuilder.ENUM_VERIFY_POSITIVE_INTEGER);
            obj.uicontrolReadNum(3, 'Subject''s Age', ExperimentGuiBuilder.ENUM_VERIFY_POSITIVE_INTEGER);
            obj.uicontrolRadios(4, 'subject''s gender', {'male', 'female'}, {'male', 'female'});            
            
            %blocks and trials number multipliers
            uipanel('tag', 'p2', 'units', 'normalized', ...
                'Position', [0.0151    0.8019    0.9806    0.0847], ...
                'Background', obj.background_color);
            
            obj.uicontrolReadNum(5, 'Blocks Number Multiplier', ExperimentGuiBuilder.ENUM_VERIFY_POSITIVE_INTEGER);
            obj.uicontrolReadNum(6, 'Trials Number Multiplier', ExperimentGuiBuilder.ENUM_VERIFY_POSITIVE_INTEGER);
            
            %panel for the experiments parameters section
            uipanel('tag', 'p3', 'units', 'normalized', ...
                'Position', [0.0151    0.2361    0.9806    0.5602], ...
                'Background', obj.background_color);
        
            %common parameters
            uipanel('tag', 'p4', 'units', 'normalized', ...
                'Position', [0.0149    0.1203    0.9806    0.1077], ...
                'Background', obj.background_color);
            
            obj.uicontrolReadNum(7, 'Response Time Allowed', ExperimentGuiBuilder.ENUM_VERIFY_POSITIVE_REAL);
            obj.uicontrolReadNum(8, 'Post Response Delay', ExperimentGuiBuilder.ENUM_VERIFY_NON_NEGATIVE_REAL);
            obj.uicontrolCheckbox(9, 'Restart Trial on Fixation Break');
            obj.uicontrolReadNum(10, 'Post Fixation Break Delay', ExperimentGuiBuilder.ENUM_VERIFY_POSITIVE_REAL);
            obj.uicontrolReadNum(11, 'Maximum Allowed Gaze Distance From Center', ExperimentGuiBuilder.ENUM_VERIFY_POSITIVE_REAL);
            obj.uicontrolRadios(12, 'Eye Tracking Method', {ExperimentGuiBuilder.ENUM_EYE_TRACKING_EYE_TRACKER, ExperimentGuiBuilder.ENUM_EYE_TRACKING_DUMMY_MODE, ExperimentGuiBuilder.ENUM_EYE_TRACKING_NO_TRACKING}, {'Eye Tracker', 'Dummy Mode', 'No Eye Tracking'});
            obj.uicontrolCheckbox(13, 'EEG');
            obj.uicontrolReadColor(14, 'Background Color');
            obj.uicontrolCheckbox(15, 'Debug Mode');
            
            obj.saveXML();
            
            %save defaults button
            uicontrol('Style', 'pushbutton', 'tag', 'sdb', 'units', 'normalized', ...
                'String', 'Save Defaults', ...
                'Position', [0.3067    0.0681    0.3646    0.0442], ...
                'FontSize', 14.0, ...
                'callback', {@saveDefaultsBtnCallback});
            
            %run experiment button
            uicontrol('Style', 'pushbutton', 'tag', 'sb', 'units', 'normalized', ...
                'String', 'Run Experiment', ...
                'Position', [0.1950    0.0046    0.5915    0.0618], ...
                'FontSize', 14.0, ...
                'callback', {@runExpBtnCallback});                        
            
            obj.run_exp_func= run_exp_func;              
            obj.uicontrols_creator= ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER;
            
            function saveDefaultsBtnCallback(~,~) 
                for uicontrol_it= 1:numel(obj.common_uicontrols.is); 
                    node_name= [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(obj.common_uicontrols.is(uicontrol_it))];
                    value= obj.common_uicontrols.values{uicontrol_it};
                    ExperimentGuiBuilder.saveDataToXML(obj.common_uicontrols_xml_node, node_name, ExperimentGuiBuilder.VALUE_TAG, value);                    
                end
                
                for uicontrol_it= 1:numel(obj.curr_exp_uicontrols.is);
                    node_name= [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(obj.curr_exp_uicontrols.is(uicontrol_it))];
                    value= obj.curr_exp_uicontrols.values{uicontrol_it};
                    ExperimentGuiBuilder.saveDataToXML(obj.curr_exp_uicontrols_xml_node, node_name, ExperimentGuiBuilder.VALUE_TAG, value);                    
                end
                
                for uicontrol_it= 1:numel(obj.custom_uicontrols.is);
                    node_name= [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(obj.custom_uicontrols.is(uicontrol_it))];
                    curr_custom_control_handle= obj.custom_uicontrols.handles(uicontrol_it);
                    curr_custom_control_get_value_func= obj.custom_uicontrols.get_value_funcs{uicontrol_it};
                    value= curr_custom_control_get_value_func(curr_custom_control_handle);
                    ExperimentGuiBuilder.saveDataToXML(obj.curr_exp_uicontrols_xml_node, ExperimentGuiBuilder.VALUE_TAG, node_name, value);                    
                end
                
                obj.saveXML();                       
            end 
            
            function saveUIControlsPos(~,~)
                for uicontrol_it= 1:numel(obj.common_uicontrols.is); 
                    node_name= [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(obj.common_uicontrols.is(uicontrol_it))];
                    pos= get(obj.common_uicontrols.handles(uicontrol_it),'position');
                    ExperimentGuiBuilder.saveDataToXML(obj.common_uicontrols_xml_node, node_name, ExperimentGuiBuilder.POS_TAG, pos);
                end
                
                for uicontrol_it= 1:numel(obj.curr_exp_uicontrols.is); 
                    node_name= [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(obj.curr_exp_uicontrols.is(uicontrol_it))];
                    pos= get(obj.curr_exp_uicontrols.handles(uicontrol_it),'position');                    
                    ExperimentGuiBuilder.saveDataToXML(obj.curr_exp_uicontrols_xml_node, node_name, ExperimentGuiBuilder.POS_TAG, pos);
                end
                
                for uicontrol_it= 1:numel(obj.custom_uicontrols.is)
                    node_name= [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(obj.custom_uicontrols.is(uicontrol_it))];
                    pos= get(obj.custom_uicontrols.handles(uicontrol_it),'position');       
                    ExperimentGuiBuilder.saveDataToXML(obj.curr_exp_uicontrols_xml_node, ExperimentGuiBuilder.POS_TAG, node_name, pos);                                
                end
                
                obj.saveXML();
            end
            
            function runExpBtnCallback(~,~)
                cd(get(obj.fig,'userdata'));
                obj.run_exp_func();
                                
                for control_i= 1:numel(obj.custom_uicontrols.is)
                    curr_custom_control_exp_end_value_updater= obj.custom_uicontrols.on_exp_end_value_updaters{control_i};
                    if ~isempty(curr_custom_control_exp_end_value_updater)                       
                        updated_value= curr_custom_control_exp_end_value_updater();
                        node_name= [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(obj.custom_uicontrols.is(control_i))];                         
                        ExperimentGuiBuilder.saveDataToXML(obj.curr_exp_uicontrols_xml_node, node_name, ExperimentGuiBuilder.VALUE_TAG, updated_value);                                                                                          
                    end
                end                                
                
                for control_i= 1:numel(obj.curr_exp_uicontrols.is)
                    if ~isempty(obj.curr_exp_uicontrols.on_exp_end_value_updaters{control_i})
                        obj.curr_exp_uicontrols.on_exp_end_value_updaters{control_i}();                       
                    end                                         
                end                
                
                next_subject_number= num2str(obj.common_uicontrols.values{2} + 1);
                subject_number_node_name= [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, '2'];
                ExperimentGuiBuilder.saveDataToXML(obj.common_uicontrols_xml_node, subject_number_node_name, ExperimentGuiBuilder.VALUE_TAG, next_subject_number);   
               
                obj.saveXML();                              
            end
            
            function editUIControlsPosCallback(hObject, ~)
                if strcmp(get(hObject, 'Checked'),'on')
                    set(hObject, 'Checked', 'off');
                else
                    set(hObject, 'Checked', 'on');
                end

               plotedit(obj.fig, 'toggle');
            end
        end
        
        function uicontrolReadNum(obj, control_i, parameter_name, input_verifier)                        
            [value, position, extra_data]= obj.extractUIControlParamsFromXML(@obj.extractDoubleValueFromXML, [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(control_i)]);                                                                                          
            if numel(value)~=1 || isnan(value)
                value= [];
            end
            
            button_group= uipanel('tag', ['c',num2str(control_i)], ...
                'Position', position, ...
                'Background', obj.background_color, ...
                'UserData', extra_data, ...
                'BorderWidth', 0);
            
            uicontrol(button_group, 'Style','text', 'units', 'normalized', ...
                'String', parameter_name, ...
                'Position', [0.05, 0.25, 0.7, 0.5], ...
                'FontSize', 10.0, ...
                'BackgroundColor', obj.background_color);
            
            uicontrol(button_group, 'Style', 'edit', 'units', 'normalized', ...
                'String', value, ...
                'position', [0.8, 0.05, 0.15, 0.9], ...
                'callback', {@etextCallback, control_i, obj.uicontrols_creator});
            
            obj.updateParamsStruct(control_i, value, button_group);            
            if obj.uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                obj.saveXML();
            end
                                                                                     
            function etextCallback(hObject, ~, uicontrol_i, uicontrols_creator)
                input= get(hObject,'string');
                if ( ExperimentGuiBuilder.VARIABLE_VERIFIERS{input_verifier}(input) )
                    if uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER;
                        value_vec_i= find(obj.common_uicontrols.is==uicontrol_i, 1);
                        obj.common_uicontrols.values{value_vec_i}= str2double(input);
                    elseif uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                        value_vec_i= find(obj.curr_exp_uicontrols.is==uicontrol_i, 1);
                        obj.curr_exp_uicontrols.values{value_vec_i}= str2double(input);
                    end
                else 
                    if uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER;
                        value_vec_i= find(obj.common_uicontrols.is==uicontrol_i, 1);
                        set(hObject,'string', obj.common_uicontrols.values{value_vec_i});                       
                    elseif uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                        value_vec_i= find(obj.curr_exp_uicontrols.is==uicontrol_i, 1);
                        set(hObject,'string', obj.curr_exp_uicontrols.values{value_vec_i});                        
                    end                   
                end
            end                        
        end

        function uicontrolReadMultipleNums(obj, control_i, parameter_name, nums_nr, input_verifiers)
            if nums_nr>20
                error('uicontrolReadMultipleNums:tooManyVariables', 'Too many variables were asked to be handled by uicontrolReadMultipleNums (limit = 20)');
            end                        
            
            [values, position, extra_data]= obj.extractUIControlParamsFromXML(@obj.extractDoubleVecValueFromXML, [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(control_i)]);
            if isempty(values) || any(isnan(values)) || numel(values)<nums_nr
                values= zeros(1,nums_nr);
            end
            
            if numel(input_verifiers)<nums_nr
                input_verifiers= [input_verifiers, input_verifiers(end)*ones(1,nums_nr-numel(input_verifiers))];
            end
            
            button_group= uipanel('tag', ['c',num2str(control_i)], ...
                'Position', position, ...                
                'Background', obj.background_color, ...
                'UserData', extra_data, ...
                'BorderWidth', 0);
                        
            uicontrol(button_group, 'Style','text', 'units', 'normalized', ... 
                'String', parameter_name, ... 
                'Position', [0.05 0.1, 0.4, 0.8], ... 
                'FontSize', 10.0, ... 
                'BackgroundColor', obj.background_color);    
                        
            edit_controls_size= 0.5/nums_nr - 0.025;
            for edit_control_i= 1:nums_nr
                uicontrol(button_group, 'Style', 'edit', 'units', 'normalized', ...
                    'String', values(edit_control_i), ... 
                    'position', [0.5 + (edit_controls_size+0.025)*(edit_control_i-1), 0.15, edit_controls_size, 0.7], ...                
                    'callback', {@etextCallback, control_i, edit_control_i, obj.uicontrols_creator});     
            end
            
            obj.updateParamsStruct(control_i, values, button_group);
            if obj.uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                obj.saveXML();
            end
            
            function etextCallback(hObject, ~, uicontrol_i, edit_control_i, uicontrols_creator)
                input= get(hObject,'string');                 
                if ( ExperimentGuiBuilder.VARIABLE_VERIFIERS{input_verifiers(edit_control_i)}(input) )                                         
                    if uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER; 
                        value_vec_i= find(obj.common_uicontrols.is==uicontrol_i, 1);
                        obj.common_uicontrols.values{value_vec_i}(edit_control_i)= str2double(input);
                    elseif uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                        value_vec_i= find(obj.curr_exp_uicontrols.is==uicontrol_i, 1);
                        obj.curr_exp_uicontrols.values{value_vec_i}(edit_control_i)= str2double(input);
                    end
                else                   
                    if uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER;
                        value_vec_i= find(obj.common_uicontrols.is==uicontrol_i, 1);
                        set(hObject,'string', obj.common_uicontrols.values{value_vec_i}(edit_control_i));
                    elseif uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                        value_vec_i= find(obj.curr_exp_uicontrols.is==uicontrol_i,  1);
                        set(hObject,'string', obj.curr_exp_uicontrols.values{value_vec_i}(edit_control_i));
                    end
                end                                                       
            end
        end
        
        function uicontrolCheckbox(obj, control_i, parameter_name)                        
            [value, position, extra_data]= obj.extractUIControlParamsFromXML(@obj.extractDoubleValueFromXML, [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(control_i)]);
            if numel(value)~=1 || any(isnan(value)) 
                value= 0;
            end
            
            checkbox_h= uicontrol('Style', 'checkbox', 'tag', ['c',num2str(control_i)], 'units', 'normalized', ...
                'String', parameter_name, 'FontSize', 10.0, ...
                'Position', position, ... 
                'value', value, ...
                'UserData', extra_data, ...
                'BackgroundColor', obj.background_color, ...
                'callback', {@checkboxCallback, control_i, obj.uicontrols_creator});
            
            obj.updateParamsStruct(control_i, value, checkbox_h);
            if obj.uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                obj.saveXML();
            end
            
            function checkboxCallback(hObject, ~, uicontrol_i, uicontrols_creator)                                                                  
                if uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER;
                    value_vec_i= find(obj.common_uicontrols.is==uicontrol_i, 1);
                    obj.common_uicontrols.values{value_vec_i}= get(hObject,'value');
                elseif uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                    value_vec_i= find(obj.curr_exp_uicontrols.is==uicontrol_i, 1);
                    obj.curr_exp_uicontrols.values{value_vec_i}= get(hObject,'value');
                end                               
            end   
        end

        function uicontrolRadios(obj, control_i, parameter_name, possible_values, possible_values_strs, sessions_nr_for_auto_toggle)             
            [value, position, curr_radios_iterator_val]= obj.extractUIControlParamsFromXML(@ExperimentGuiBuilder.extractStringValueFromXML, [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(control_i)]);
            if isempty(value) || any(isnan(value) )
                value= possible_values{1};
            end
                        
            if ischar(value) && all(ismember(value, '0123456789+-.eEdD '))
                value= str2num(value);
            end
            
            if isempty(curr_radios_iterator_val)
                curr_radios_iterator_val = 1;
            end
            
            button_group= uibuttongroup('tag', ['c',num2str(control_i)], ...
                'Position', position, ...         
                'UserData', curr_radios_iterator_val, ...
                'BackgroundColor', obj.background_color, ...                
                'SelectionChangeFcn', {@radiosCallback, control_i, obj.uicontrols_creator});
                       
            uicontrol(button_group, 'Style','text', 'units', 'normalized', ... 
                'String', parameter_name, ... 
                'Position', [0.05 0.2, 0.35, 0.6], ... 
                'FontSize', 10.0, ... 
                'BackgroundColor', obj.background_color);    
            
            possible_values_nr= numel(possible_values);
            radios_sectros_height= 0.9/possible_values_nr;
            for possible_value_i= 1:possible_values_nr        
                uicontrol(button_group, 'Style','radiobutton', ...
                    'units', 'normalized', 'String', possible_values_strs{possible_value_i}, ...
                    'Value', isequal(value, possible_values{possible_value_i}), ...
                    'Position', [0.45, 0.05 + (possible_values_nr-(possible_value_i-0.5))*radios_sectros_height - 0.15, 0.5 ,0.3], ...
                    'FontSize', 10.0, ... 
                    'UserData', possible_values{possible_value_i}, ...
                    'BackgroundColor', obj.background_color);
            end                
            
            obj.updateParamsStruct(control_i, value, button_group, @onExpEndToggler);
            if obj.uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                obj.saveXML();
            end
            
            function radiosCallback(~, eventdata, uicontrol_i, uicontrols_creator)                                
                if uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER;
                    value_vec_i= find(obj.common_uicontrols.is==uicontrol_i, 1);                    
                    obj.common_uicontrols.values{value_vec_i}= get(eventdata.NewValue,'UserData');                     
                elseif uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                    value_vec_i= find(obj.curr_exp_uicontrols.is==uicontrol_i, 1);
                    obj.curr_exp_uicontrols.values{value_vec_i}= get(eventdata.NewValue,'UserData');                     
                end     
            end
            
            function onExpEndToggler()
                value_vec_i= find(obj.curr_exp_uicontrols.is==control_i, 1);     
                node_name= [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(control_i)];  
                if curr_radios_iterator_val == sessions_nr_for_auto_toggle                   
                    curr_radio_val = obj.curr_exp_uicontrols.values{value_vec_i};
                    curr_radio_val_i = find(cellfun(@(e) isequal(e,curr_radio_val), possible_values));
                    if isempty(curr_radio_val_i)
                        new_radio_val_i = 1;
                    else
                        new_radio_val_i = mod(curr_radio_val_i, numel(possible_values)) + 1;
                    end
                    ExperimentGuiBuilder.saveDataToXML(obj.curr_exp_uicontrols_xml_node, node_name, ExperimentGuiBuilder.VALUE_TAG, possible_values{new_radio_val_i});                    
                elseif sessions_nr_for_auto_toggle ~= 0
                    ExperimentGuiBuilder.saveDataToXML(obj.curr_exp_uicontrols_xml_node, node_name, ExperimentGuiBuilder.EXTRA_DATA_TAG, mod(curr_radios_iterator_val, sessions_nr_for_auto_toggle) + 1);
                end                                                
            end
        end

        function uicontrolReadColor(obj, control_i, parameter_name)                        
            [rgb, position, extra_data]= obj.extractUIControlParamsFromXML(@ExperimentGuiBuilder.extractDoubleVecValueFromXML, [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(control_i)]);
            
            if numel(rgb)~=3 || any(isnan(rgb))
                rgb= [0.0, 0.0, 0.0];
            end
            
            button_group= uipanel('tag', ['c',num2str(control_i)], ...
                'Position', position, ...
                'Background', obj.background_color, ...
                'UserData', extra_data, ...
                'BorderWidth', 0);
            
            uicontrol(button_group, 'Style', 'pushbutton', 'units', 'normalized', ...
                'String', parameter_name, ...
                'Position', [0.05, 0.05, 0.7, 0.9], ...
                'FontSize', 10.0, ...
                'BackgroundColor', obj.background_color, ....          
                'callback', {@readColorCallback, control_i, obj.uicontrols_creator});                       

            read_color_display= uipanel(button_group, 'units', 'normalized', ...
                'Position', [0.8, 0.05, 0.15, 0.9], ...
                'Background', rgb);
            
            obj.updateParamsStruct(control_i, rgb, button_group);
            if obj.uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                obj.saveXML();
            end
            
            function readColorCallback(~,~, uicontrol_i, uicontrols_creator)
                if uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER;
                    value_vec_i= find(obj.common_uicontrols.is==uicontrol_i, 1);
                    new_color= uisetcolor( obj.common_uicontrols.values{value_vec_i} );
                    obj.common_uicontrols.values{value_vec_i}= new_color;
                elseif uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                    value_vec_i= find(obj.curr_exp_uicontrols.is==uicontrol_i, 1);
                    new_color= uisetcolor( obj.curr_exp_uicontrols.values{value_vec_i} );
                    obj.curr_exp_uicontrols.values{value_vec_i}= new_color;                    
                end
                
                set(read_color_display, 'Background', new_color);
            end    
        end

        function uicontrolReadNumsGroup(obj, control_i, parameter_name, input_verifier)                        
            [values, position, extra_data]= obj.extractUIControlParamsFromXML(@obj.extractDoubleVecValueFromXML, [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(control_i)]);
            if isempty(values) || any(isnan(values))
                values= [];
            end
            
            button_group= uipanel('tag', ['c',num2str(control_i)], ...
                'Position', position, ...
                'Background', obj.background_color, ...
                'UserData', extra_data, ...
                'BorderWidth', 0);
                        
            uicontrol(button_group, 'Style','text', 'units', 'normalized', ... 
                'String', parameter_name, ... 
                'Position', [0.05, 0.25, 0.3, 0.5], ... 
                'FontSize', 10.0, ... 
                'BackgroundColor', obj.background_color);        

            uicontrol(button_group, 'Style', 'edit', 'units', 'normalized', ...
                'Position', [0.375, 0.2, 0.15, 0.6], ...
                'callback', {@addNumToGroupCallback, control_i, obj.uicontrols_creator});

            uicontrol(button_group, 'Style', 'pushbutton', 'units', 'normalized', ...
                'String', 'delete', ...
                'Position', [0.55, 0.2, 0.15, 0.6], ...
                'FontSize', 10.0, ...
                'BackgroundColor', obj.background_color, ....
                'callback', {@deleteNumFromGroupCallback, control_i, obj.uicontrols_creator});     

            nums_group_display= uicontrol(button_group, 'Style', 'listbox', 'units', 'normalized', ...
                'max', 2, 'string', strsplit(num2str(values),' '), ...
                'Position', [0.725, 0.05, 0.25, 0.9]);    
            
            obj.updateParamsStruct(control_i, values, button_group);
            if obj.uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                obj.saveXML();
            end
            
            function addNumToGroupCallback(hObject,~, uicontrol_i, uicontrols_creator)
                input= get(hObject,'string');
                if (ExperimentGuiBuilder.VARIABLE_VERIFIERS{input_verifier}(input) )
                    set(nums_group_display, 'string', [get(nums_group_display,'string')', input]) ;                                                            
                    if uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER;
                        value_vec_i= find(obj.common_uicontrols.is==uicontrol_i, 1);
                        obj.common_uicontrols.values{value_vec_i}= [obj.common_uicontrols.values{value_vec_i}, str2double(input)];
                    elseif uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                         value_vec_i= find(obj.curr_exp_uicontrols.is==uicontrol_i, 1);
                        obj.curr_exp_uicontrols.values{value_vec_i}= [obj.curr_exp_uicontrols.values{value_vec_i}, str2double(input)];
                    end
                end
                
                set(hObject, 'string', '');
            end

            function deleteNumFromGroupCallback(~, ~, uicontrol_i, uicontrols_creator)
                nums_group_display_str= get(nums_group_display, 'string');
                nums_group_display_value= get(nums_group_display, 'value');
                if numel(nums_group_display_str)==numel(nums_group_display_value)
                    return;
                end

                nums_group_display_str(nums_group_display_value)= [];
                set(nums_group_display, 'string', nums_group_display_str, 'value', 1);                
                                
                if uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER;
                    value_vec_i= find(obj.common_uicontrols.is==uicontrol_i, 1);
                    obj.common_uicontrols.values{value_vec_i}=  str2num( char(get(nums_group_display,'string')) )';                    
                elseif uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                    value_vec_i= find(obj.curr_exp_uicontrols.is==uicontrol_i, 1);
                    obj.curr_exp_uicontrols.values{value_vec_i}=  str2num( char(get(nums_group_display,'string')) )';                     
                end
            end
        end                
        
        function uicontrolReadStr(obj, control_i, parameter_name)
            [value, position]= obj.extractUIControlParamsFromXML(@ExperimentGuiBuilder.extractStringValueFromXML, [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(control_i)]);            
            
            button_group= uipanel('tag', ['c',num2str(control_i)], ...
                'Position', position, ...
                'Background', obj.background_color, ...
                'BorderWidth', 0);
            
            uicontrol(button_group, 'Style','text', 'units', 'normalized', ...
                'String', parameter_name, ...
                'Position', [0.05, 0.25, 0.35, 0.5], ...
                'FontSize', 10.0, ...
                'BackgroundColor', obj.background_color);
            
            uicontrol(button_group, 'Style', 'edit', 'units', 'normalized', ...
                'String', value, ...
                'position', [0.45, 0.05, 0.5, 0.9], ...
                'FontSize', 14, ...
                'callback', {@etextCallback, control_i, obj.uicontrols_creator});
            
            obj.updateParamsStruct(control_i, value, button_group);            
            if obj.uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                obj.saveXML();
            end
                                                                                     
            function etextCallback(hObject, ~, uicontrol_i, uicontrols_creator)
                input= get(hObject,'string');                
                if uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER;
                    value_vec_i= find(obj.common_uicontrols.is==uicontrol_i, 1);
                    obj.common_uicontrols.values{value_vec_i}= input;
                elseif uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                    value_vec_i= find(obj.curr_exp_uicontrols.is==uicontrol_i, 1);
                    obj.curr_exp_uicontrols.values{value_vec_i}= input;
                end                                     
            end                
        end
        
        function uicontrolReadKey(obj, control_i, parameter_name)
            [value, position]= obj.extractUIControlParamsFromXML(@ExperimentGuiBuilder.extractDoubleValueFromXML, [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(control_i)]);            
            if isnan(value)
                value= [];
            end
            
            button_group= uipanel('tag', ['c',num2str(control_i)], ...
                'Position', position, ...
                'Background', obj.background_color, ...
                'UserData', [], ...                
                'BorderWidth', 0);
            
            uicontrol(button_group, 'Style', 'pushbutton', 'units', 'normalized', ...
                'String', parameter_name, ...
                'Position', [0.05, 0.15, 0.56, 0.7], ...
                'FontSize', 10.0, ...
                'BackgroundColor', obj.background_color, ....
                'callback', {@readKey, control_i, obj.uicontrols_creator});     
            
            key_display= uicontrol(button_group, 'Style', 'edit', 'units', 'normalized', ...
                'String', KbName(value), ...
                'enable', 'inactive', ...
                'position', [0.62, 0.15, 0.37, 0.7], ...
                'FontSize', 11);
            
            obj.updateParamsStruct(control_i, value, button_group);            
            if obj.uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                obj.saveXML();
            end
                                                                                     
            function readKey(~, ~, uicontrol_i, uicontrols_creator)
                set(key_display, 'string', '<<Press Key>>');
                pause(0.01);
                while (1)
                    [~, ~, key_codes_vec, ~]= KbCheck;
                    if any(key_codes_vec)
                        break;
                    end
                    [~,~,buttons,~,~,] = GetMouse();
                    if any(buttons)
                        break;
                    end
                end
                
                pressed_key= find(key_codes_vec,1);
                if isempty(pressed_key) || pressed_key==ExperimentGuiBuilder.KEY_CODES_ESC
                    set(key_display, 'string', KbName(get(button_group, 'UserData')));
                else
                    set(key_display, 'string', KbName(pressed_key));
                    set(button_group, 'UserData',pressed_key);
                    if uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER;
                        value_vec_i= find(obj.common_uicontrols.is==uicontrol_i, 1);
                        obj.common_uicontrols.values{value_vec_i}= pressed_key;
                    elseif uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                        value_vec_i= find(obj.curr_exp_uicontrols.is==uicontrol_i, 1);
                        obj.curr_exp_uicontrols.values{value_vec_i}= pressed_key;
                    end   
                end                
            end                        
        end
        
        function uicontrolLoadFile(obj, control_i, parameter_name, file_types, load_file_window_title)
            [value, position]= obj.extractUIControlParamsFromXML(@ExperimentGuiBuilder.extractStringValueFromXML, [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(control_i)]);            
            if ~isempty(value)
                [obj.current_folder_load_file, load_file_name, load_file_ext] = fileparts(value);
            else
                load_file_name = '';
                load_file_ext = '';
            end
            
            file_types_str = [];
            for file_type_i = 1:numel(file_types)
                file_types_str = [file_types_str, '*.', file_types{file_type_i}, ';']; %#ok<AGROW>
            end
            
            if nargin < 5
                load_file_window_title = 'Load File';            
            end
            
            button_group= uipanel('tag', ['c',num2str(control_i)], ...
                'Position', position, ...
                'Background', obj.background_color, ...
                'BorderWidth', 0);
            
            uicontrol(button_group, 'Style', 'text', 'units', 'normalized', ...
                'String', parameter_name, ...
                'Position', [0.05, 0.6, 0.9, 0.34], ...
                'FontSize', 10.0, ...
                'BackgroundColor', obj.background_color);
            
            uicontrol(button_group, 'Style', 'pushbutton', 'units', 'normalized', ...
                'Position', [0.05    0.01    0.2    0.5], ...
                'CData', obj.load_file_icon, ...
                'callback', {@loadFileBtnCallback, control_i, obj.uicontrols_creator});
            
            load_file_display_pane= uicontrol(button_group, 'Style', 'edit', 'units', 'normalized', ...
                'string', [load_file_name, '.', load_file_ext], ...
                'enable', 'inactive', 'Position', [0.3      0.01      0.65      0.5]);                                                       
            
            obj.updateParamsStruct(control_i, value, button_group);            
            if obj.uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                obj.saveXML();
            end
            
            function loadFileBtnCallback(~, ~, uicontrol_i, uicontrols_creator)
                [file_name, path_name, ~] = uigetfile({file_types_str}, load_file_window_title, obj.current_folder_load_file, 'MultiSelect', 'off');
                if file_name == 0
                    return;
                end
                
                obj.current_folder_load_file = path_name;
                input = fullfile(path_name, file_name);
                set(load_file_display_pane, 'string', file_name);
                
                if uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER;
                    value_vec_i= find(obj.common_uicontrols.is==uicontrol_i, 1);
                    obj.common_uicontrols.values{value_vec_i}= input;
                elseif uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                    value_vec_i= find(obj.curr_exp_uicontrols.is==uicontrol_i, 1);
                    obj.curr_exp_uicontrols.values{value_vec_i}= input;
                end                       
            end                       
        end
        
        % parameters:
        % 1. obj -> the ExperimentGuiBilder object
        % 2. control_i -> control index
        % 3. uicontrol_handle -> a handle to a MATLAB uicontrol
        % 4. get_value_func -> a handle to a function with the following constraints:
        %    return value -> a string representing the current uicontrol user value (in string form)     
        %    argument #1 -> a handle to the MATLAB uicontrol
        % 5. set_value_func -> a handle to a function with the following constraints:
        %    return value -> void
        %    argument #1 -> a handle to the MATLAB uicontrol
        %    argument #2 -> the value to set the uicontrol to (must be in string form)     
        % 6. on_exp_end_value_updater (optional) -> a handle to a function that updates the value of the uicontrol 
        %                                           when the experiment ends.
        %    this function has the following constraints:
        %    return value -> the value to update the uicontrol with. (must be in string form)     
        %    arguments -> void
        function uicontrolCustom(obj, control_i, uicontrol_handle, get_value_func, set_value_func, on_exp_end_value_updater)
            if nargin<6
                on_exp_end_value_updater= [];
            end
            
            [value, position, ~]= obj.extractUIControlParamsFromXML(@ExperimentGuiBuilder.extractStringValueFromXML, [ExperimentGuiBuilder.XML_NODES_NAMES_PREFIX, num2str(control_i)]);
            if isempty(value) || any(isnan(value) )
                value= [];
            end
                      
            set_value_func(uicontrol_handle, value, extra_data);
            set(uicontrol_handle,'position', position);
            set(uicontrol_handle,'Background', obj.background_color);
                                    
            obj.custom_uicontrols.is= [obj.custom_uicontrols.is, control_i];
            obj.custom_uicontrols.get_value_funcs= [obj.custom_uicontrols.get_value_funcs, {get_value_func}];
            obj.custom_uicontrols.set_value_funcs= [obj.custom_uicontrols.set_value_funcs, {set_value_func}];
            obj.custom_uicontrols.handles= [obj.custom_uicontrols.handles; uicontrol_handle];
            obj.custom_uicontrols.on_exp_end_value_updaters= [obj.custom_uicontrols.on_exp_end_value_updaters, {on_exp_end_value_updater}];
            
            obj.saveXML();            
        end
        
        function values= getCommonParamsValues(obj)
            values= obj.common_uicontrols.values;
            
            if values{1} == ExperimentGuiBuilder.ENUM_LAB1
                selected_lab_node= obj.lab_consts_xml_dom.getElementsByTagName('LAB1').item(0);
                lab_room= ExperimentGuiBuilder.ENUM_LAB1;
            elseif values{1} == ExperimentGuiBuilder.ENUM_LAB2
                selected_lab_node= obj.lab_consts_xml_dom.getElementsByTagName('LAB2').item(0);
                lab_room= ExperimentGuiBuilder.ENUM_LAB2;
            elseif values{1} == ExperimentGuiBuilder.ENUM_LAB3
                selected_lab_node= obj.lab_consts_xml_dom.getElementsByTagName('LAB3').item(0);
                lab_room= ExperimentGuiBuilder.ENUM_LAB3;
            end
            
            subject_distance_from_screen= str2double( selected_lab_node.getElementsByTagName('SUBJECT_DISTANCE_FROM_SCREEN').item(0).getTextContent );
            screen_width= str2double( selected_lab_node.getElementsByTagName('SCREEN_WIDTH').item(0).getTextContent );
            screen_height= str2double( selected_lab_node.getElementsByTagName('SCREEN_HEIGHT').item(0).getTextContent );
            gamme_table_full_path= char( selected_lab_node.getElementsByTagName('GAMMA_TABLE_FULL_PATH').item(0).getTextContent );
            
            values{1}= {lab_room, subject_distance_from_screen, screen_width, screen_height, gamme_table_full_path};
        end
        
        function values= getCurrExpParamsValues(obj)
            custom_controls_values= cell(1,numel(obj.custom_uicontrols.is));
            for custom_control_i= 1:numel(obj.custom_uicontrols.is)
                curr_custom_control_handle= obj.custom_uicontrols.handles(custom_control_i);
                curr_custom_control_get_value_func= obj.custom_uicontrols.get_value_funcs{custom_control_i};
                custom_controls_values{custom_control_i}= curr_custom_control_get_value_func(curr_custom_control_handle);
            end
            
            combined_controls_is_vec= [obj.curr_exp_uicontrols.is, obj.custom_uicontrols.is];
            [~, sort_is]= sort(combined_controls_is_vec);
            combined_values_vec= [obj.curr_exp_uicontrols.values, custom_controls_values];
            values= combined_values_vec(sort_is);           
        end
                        
        function show(obj)
            set(obj.fig, 'Visible', 'on');
        end
        
        function hide(obj)
            set(obj.fig, 'Visible', 'off');
            set(obj.fig, 'CurrentObject', obj.fig);
        end
        
        function close(obj)
            close(obj.fig);
        end
    end               
    
    methods (Access=private, Static)
        function res= doesXMLNodeExist(xml_dom, node_name)
            nodes_list_len= xml_dom.getElementsByTagName(node_name).getLength();  
            if nodes_list_len>0
                res= true;
            else
                res= false;
            end
        end
        
        function data= extractDoubleValueFromXML(uicontrols_group_node, node_name)
            node= uicontrols_group_node.getElementsByTagName(node_name).item(0);            
            data= str2double(node.getElementsByTagName(ExperimentGuiBuilder.VALUE_TAG).item(0).getTextContent);                        
        end
        
        function data= extractDoubleVecValueFromXML(uicontrols_group_node, node_name)
            node= uicontrols_group_node.getElementsByTagName(node_name).item(0);            
            data= node.getElementsByTagName(ExperimentGuiBuilder.VALUE_TAG).item(0).getTextContent;
            data= sscanf(char(data),'%f')';            
        end    
        
        function data= extractStringValueFromXML(uicontrols_group_node, node_name)
            node= uicontrols_group_node.getElementsByTagName(node_name).item(0);            
            data= char(node.getElementsByTagName(ExperimentGuiBuilder.VALUE_TAG).item(0).getTextContent);                        
        end
        
        function data= extractPosFromXML(uicontrols_group_node, node_name)            
            node= uicontrols_group_node.getElementsByTagName(node_name).item(0);
            data= node.getElementsByTagName(ExperimentGuiBuilder.POS_TAG).item(0).getTextContent;
            data= sscanf(char(data),'%f')';            
        end
        
        function data = extractExtraDataFromXML(uicontrols_group_node, node_name) 
            node= uicontrols_group_node.getElementsByTagName(node_name).item(0);
            data= node.getElementsByTagName(ExperimentGuiBuilder.EXTRA_DATA_TAG).item(0).getTextContent;
            data= sscanf(char(data),'%f')';      
        end
        
        function saveDataToXML(uicontrols_group_node, node_name, tag_name, value)
            if ischar(value)
                ExperimentGuiBuilder.saveStringByNodeName(uicontrols_group_node, node_name, tag_name, value);
            elseif numel(value)>1
                ExperimentGuiBuilder.saveDoubleVecByNodeName(uicontrols_group_node, node_name, tag_name,value);
            else
                ExperimentGuiBuilder.saveDoubleByNodeName(uicontrols_group_node, node_name, tag_name,value);
            end                          
        end                                
                            
        function saveDoubleByNodeName(uicontrols_group_node, node_name, tag_name, value)
            node= uicontrols_group_node.getElementsByTagName(node_name).item(0);
            node.getElementsByTagName(tag_name).item(0).setTextContent(num2str(value));
        end
        
        function saveDoubleVecByNodeName(uicontrols_group_node, node_name, tag_name, vec)
            node= uicontrols_group_node.getElementsByTagName(node_name).item(0);
            data_str= sprintf('%f ',double(vec));
            data_str= data_str(1:end-1);
            node.getElementsByTagName(tag_name).item(0).setTextContent(num2str(data_str));
        end
        
        function saveStringByNodeName(uicontrols_group_node, node_name, tag_name, value)
            node= uicontrols_group_node.getElementsByTagName(node_name).item(0);
            node.getElementsByTagName(tag_name).item(0).setTextContent(value);
        end
            
        function res= isStrAValidPositiveInteger(str)
            res= ~isempty(str) && isempty(find(~isstrprop(str,'digit'),1)) && ~strcmp(str(1),'0');                
        end
        
        function res= isStrAValidNonNegativeInteger(str)
            if ~isempty(str) && isempty(find(~isstrprop(str,'digit'),1)) 
                if numel(str)==1 || ~strcmp(str(1),'0')
                    res= true;
                else
                    res= false;
                end
            else
                res= false;
            end
        end
        
        function res= isStrAValidReal(str)
            if isempty(str)
                res= false;
                return;
            end
            
            non_digit_chars_is= find(~isstrprop(str,'digit'));
            if ExperimentGuiBuilder.isStrAValidNonNegativeInteger(str) || ...
               ExperimentGuiBuilder.strHasOnlyAValidDecimalPoint(str, non_digit_chars_is) && (non_digit_chars_is==2 || ~strcmp(str(1),'0')) || ...
               ExperimentGuiBuilder.strHasOnlyAValidNegationSign(str, non_digit_chars_is) && ~strcmp(str(2),'0') || ...
               ExperimentGuiBuilder.strHasOnlyBothValidDecimalPointAndNegationSign(str, non_digit_chars_is) && (non_digit_chars_is(2)==3 || ~strcmp(str(2),'0'))            
                res= true;
            else
                res= false;
            end                        
        end
        
        function res= isStrAValidPositiveReal(str)
            if isempty(str)
                res= false;
                return;
            end
            
            non_digit_chars_is= find(~isstrprop(str,'digit'));
            if ExperimentGuiBuilder.isStrAValidPositiveInteger(str) || ...
                ExperimentGuiBuilder.strHasOnlyAValidDecimalPoint(str, non_digit_chars_is)                      
                res= true;
            else
                res= false;
            end       
        end                                
        
        function res= isStrAValidNonNegativeReal(str)
            if isempty(str)
                res= false;
                return;
            end
            
            non_digit_chars_is= find(~isstrprop(str,'digit'));
            if ExperimentGuiBuilder.isStrAValidNonNegativeInteger(str) || ...
               ExperimentGuiBuilder.strHasOnlyAValidDecimalPoint(str, non_digit_chars_is) && (non_digit_chars_is==2 || ~strcmp(str(1),'0'))                      
                res= true;
            else
                res= false;
            end       
        end          
        
        function res= strHasOnlyAValidDecimalPoint(str, non_digit_chars_is)
            res= numel(non_digit_chars_is)==1 && ...
                 strcmp(str(non_digit_chars_is),'.') && ...
                 non_digit_chars_is~=1 && ...
                 non_digit_chars_is~=numel(str);                                   
        end
            
        function res= strHasOnlyAValidNegationSign(str, non_digit_chars_is)
            res= numel(non_digit_chars_is)==1 && strcmp(str(non_digit_chars_is),'-') && non_digit_chars_is==1 && ~strcmp(str(2),'0');
        end
        
        function res= strHasOnlyBothValidDecimalPointAndNegationSign(str, non_digit_chars_is)
            res= numel(non_digit_chars_is)==2 && ...
                 strcmp(str(non_digit_chars_is(1)),'-') && ...
                 strcmp(str(non_digit_chars_is(2)),'.') && ...
                 non_digit_chars_is(1)==1 && ...
                 non_digit_chars_is(2)~=2 && ...
                 non_digit_chars_is(2)~=numel(str);                              
        end
    end
    
    methods (Access= private) 
        function [value, position, extra_data]= extractUIControlParamsFromXML(obj, params_extraction_func, uicontrol_xml_node_name)                                                                            
            if obj.uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                if ~obj.doesXMLNodeExist(obj.curr_exp_uicontrols_xml_node, uicontrol_xml_node_name)
                    uicontrol_xml_node= obj.createNewUIControlXMLNode(uicontrol_xml_node_name);
                    obj.curr_exp_uicontrols_xml_node.appendChild(uicontrol_xml_node);
                    value= [];
                    position= ExperimentGuiBuilder.DEFAULT_CURR_EXP_UICONTROL_POS;
                    extra_data = [];
                    ExperimentGuiBuilder.saveDataToXML(obj.curr_exp_uicontrols_xml_node, uicontrol_xml_node_name, ExperimentGuiBuilder.VALUE_TAG, value);                    
                    ExperimentGuiBuilder.saveDataToXML(obj.curr_exp_uicontrols_xml_node, uicontrol_xml_node_name, ExperimentGuiBuilder.POS_TAG, position);
                    ExperimentGuiBuilder.saveDataToXML(obj.curr_exp_uicontrols_xml_node, uicontrol_xml_node_name, ExperimentGuiBuilder.EXTRA_DATA_TAG, extra_data)
                else
                    value= params_extraction_func(obj.curr_exp_uicontrols_xml_node, uicontrol_xml_node_name);
                    position= ExperimentGuiBuilder.extractPosFromXML(obj.curr_exp_uicontrols_xml_node, uicontrol_xml_node_name);
                    extra_data = ExperimentGuiBuilder.extractExtraDataFromXML(obj.curr_exp_uicontrols_xml_node, uicontrol_xml_node_name);
                end
            elseif obj.uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER
                if ~obj.doesXMLNodeExist(obj.common_uicontrols_xml_node, uicontrol_xml_node_name)
                    uicontrol_xml_node= obj.createNewUIControlXMLNode(uicontrol_xml_node_name);
                    obj.common_uicontrols_xml_node.appendChild(uicontrol_xml_node);
                    value= [];
                    position= ExperimentGuiBuilder.DEFAULT_COMMON_UICONTROLS_POS(numel(obj.common_uicontrols.handles)+1,:);
                    extra_data = [];
                    ExperimentGuiBuilder.saveDataToXML(obj.common_uicontrols_xml_node, uicontrol_xml_node_name, ExperimentGuiBuilder.VALUE_TAG, value);                    
                    ExperimentGuiBuilder.saveDataToXML(obj.common_uicontrols_xml_node, uicontrol_xml_node_name, ExperimentGuiBuilder.POS_TAG, position);                    
                    ExperimentGuiBuilder.saveDataToXML(obj.common_uicontrols_xml_node, uicontrol_xml_node_name, ExperimentGuiBuilder.EXTRA_DATA_TAG, extra_data)
                else
                    value= params_extraction_func(obj.common_uicontrols_xml_node, uicontrol_xml_node_name);
                    position= ExperimentGuiBuilder.extractPosFromXML(obj.common_uicontrols_xml_node, uicontrol_xml_node_name);
                    extra_data = ExperimentGuiBuilder.extractExtraDataFromXML(obj.common_uicontrols_xml_node, uicontrol_xml_node_name);
                end
            end
        end
        
        function new_uicontrol_xml_node= createNewUIControlXMLNode(obj, uicontrol_xml_node_name)
            new_uicontrol_xml_node= obj.xml_dom.createElement(uicontrol_xml_node_name);
            uicontrol_value_xml_node= obj.xml_dom.createElement(ExperimentGuiBuilder.VALUE_TAG);            
            new_uicontrol_xml_node.appendChild(uicontrol_value_xml_node);
            uicontrol_position_xml_node= obj.xml_dom.createElement(ExperimentGuiBuilder.POS_TAG);
            new_uicontrol_xml_node.appendChild(uicontrol_position_xml_node);
            uicontrol_position_xml_node= obj.xml_dom.createElement(ExperimentGuiBuilder.EXTRA_DATA_TAG);
            new_uicontrol_xml_node.appendChild(uicontrol_position_xml_node);
        end
        
        function saveXML(obj)
            if obj.xml_file_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER;
                xmlwrite(obj.xml_file_path, obj.xml_dom);
            else
                myXMLwrite(obj.xml_file_path, obj.xml_dom);
            end
        end
        
        function updateParamsStruct(obj, control_i, variable_value, uicontrol_handle, on_exp_end_value_updater)
            if obj.uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_USER
                obj.curr_exp_uicontrols.is= [obj.curr_exp_uicontrols.is, control_i];
                obj.curr_exp_uicontrols.values= [obj.curr_exp_uicontrols.values, {variable_value}];    
                obj.curr_exp_uicontrols.handles= [obj.curr_exp_uicontrols.handles; uicontrol_handle];
                if nargin == 5
                    obj.curr_exp_uicontrols.on_exp_end_value_updaters = [obj.curr_exp_uicontrols.on_exp_end_value_updaters, {on_exp_end_value_updater}];
                else
                    obj.curr_exp_uicontrols.on_exp_end_value_updaters = [obj.curr_exp_uicontrols.on_exp_end_value_updaters, {[]}];
                end
            elseif obj.uicontrols_creator == ExperimentGuiBuilder.ENUM_UICONTROLS_CREATOR_GUI_BUILDER                                
                obj.common_uicontrols.is= [obj.common_uicontrols.is, control_i];
                obj.common_uicontrols.values= [obj.common_uicontrols.values, {variable_value}];    
                obj.common_uicontrols.handles= [obj.common_uicontrols.handles; uicontrol_handle]; 
            end
        end                               
    end        
end

