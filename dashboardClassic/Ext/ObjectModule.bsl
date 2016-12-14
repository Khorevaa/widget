﻿// ---------------------------- Функции взаимодействия ------------------------------

Функция ПолучитьНаКоординатыжатогоВиджета(ДанныеСобытия, byX, byY) Экспорт
	Координаты = Новый Структура;
	Элемент = ДанныеСобытия.srcElement;
	Попытка
		Пока Элемент.tagName <> "BODY" Цикл
			Элемент = Элемент.parentNode;	
		КонецЦикла;	
		ШиринаПоля = Элемент.clientWidth;
		ВысотаПоля = Элемент.ClientHeight;
		Если ВысотаПоля = 0 Тогда
			ВысотаПоля = Элемент.parentNode.ClientHeight;	
		КонецЕсли;
		Координаты.Вставить("left", Цел(byX*ДанныеСобытия.x/ШиринаПоля));
		Координаты.Вставить("top", Цел(byY*ДанныеСобытия.y/ВысотаПоля));
		Возврат Координаты;
	Исключение
		Возврат Неопределено;
	КонецПопытки;
КонецФункции

Функция ПолучитьВиджетНажатия(ДанныеСобытия, byX, byY, widgets_table) Экспорт
	Координаты = ПолучитьНаКоординатыжатогоВиджета(ДанныеСобытия,  byX, byY);
	Если Координаты <> Неопределено Тогда
		Для каждого widget из widgets_table Цикл
			Если (widget.left <= Координаты.left) И (widget.right >= Координаты.left) И 
				(widget.top <= Координаты.top) И (widget.bottom >= Координаты.top) Тогда
					Возврат widget;
			КонецЕсли;	
		КонецЦикла;	
	КонецЕсли;
Возврат Неопределено;
КонецФункции

// --------------------------- Функции экспорта и импорта -----------------------------

Процедура ЗагрузкаМакетов() Экспорт
	widgets_type.Очистить();
    СтрокаДанных = ПолучитьМакет("widgets_type").ПолучитьТекст();
	Структура = ПрочитатьJSONВСтруктуру(СтрокаДанных);
	ЗагрузитьДанныеИзСтруктуры( Структура, widgets_type );
	html_pattern = ПолучитьМакет("html").ПолучитьТекст();
	raphaeljs = ПолучитьМакет("raphaeljs").ПолучитьТекст();
КонецПроцедуры	

//Загрузка структуры данных
Процедура ЗагрузитьДанныеИзСтруктуры( Структура, widgets_table ) Экспорт
	widgets_table.Очистить();
	Если ТипЗнч(Структура) = Тип("Структура") Тогда
		Если Структура.Свойство("widgets") Тогда
			Если Тип(Структура.widgets) = Тип("Массив") Тогда
				Для каждого Элемент Из Структура.widgets Цикл
					ДанныеСтроки = widgets_table.Добавить();
					ЗаполнитьЗначенияСвойств( ДанныеСтроки, Элемент);
					Если Элемент.Свойство("id") Тогда
						Если Элемент.id = "00000000-0000-0000-0000-000000000000" Тогда
							ДанныеСтроки.id = Новый УникальныйИдентификатор();
						Иначе
							ДанныеСтроки.id = Новый УникальныйИдентификатор(Элемент.id);
						КонецЕсли;
					КонецЕсли;
				КонецЦикла;
			Иначе
				widgets_table.Загрузить(Структура.widgets);
			КонецЕсли;	
		КонецЕсли;
		Значения = Новый Структура();
		Если widgets_table = widgets Тогда
			Если Структура.Свойство("Значения") Тогда
				Значения = Структура.Значения;
			КонецЕсли;
			Если Структура.Свойство("stepsX") Тогда
				stepsX = Структура.stepsX; 					
			КонецЕсли;
			Если Структура.Свойство("stepsY") Тогда
				stepsY = Структура.stepsY; 					
			КонецЕсли;
		ИначеЕсли widgets_table = widgets_type Тогда
			stepsX_widgets = 3;
			Если Структура.Свойство("stepsX") Тогда
				stepsX_widgets = Структура.stepsX; 					
			КонецЕсли;
			stepsY_widgets = 3;
			Если Структура.Свойство("stepsY") Тогда
				stepsY_widgets = Структура.stepsY; 					
			КонецЕсли;	
		ИначеЕсли  widgets_table = widgets_load Тогда
			Если Структура.Свойство("stepsX") Тогда
				stepsX_load = Структура.stepsX; 					
			КонецЕсли;
			Если Структура.Свойство("stepsY") Тогда
				stepsY_load = Структура.stepsY; 					
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры


Функция ЗаполнитьБиблиотекуВиджетов(email) Экспорт
	ЗагрузкаМакетов();
	HttpСоединение = Новый HTTPСоединение( "widget.sikuda.ru",,,,,5);
	HttpЗапрос = Новый HTTPЗапрос("/_widgets.php?email="+email);
	мОтвет = HttpСоединение.Получить(HttpЗапрос);
	Если мОтвет.КодСостояния = 200 Тогда
		СтрокаДанных = мОтвет.ПолучитьТелоКакСтроку();	
		//JSON до 8.3.6
		Структура = ПрочитатьJSONВСтруктуру(СтрокаДанных);
		//после 8.3.6 
 		//ЧтениеJSON = Новый ЧтениеJSON();
		//ЧтениеJSON.УстановитьСтроку(СтрокаДанных);
		//Массив = ПрочитатьJSON(ЧтениеJSON);
		//ЧтениеJSON.Закрыть();
		 ЗагрузитьДанныеИзСтруктуры( Структура, widgets_type );
	Иначе
		Сообщить("Не могу сязаться с сайтом библиотеки виджетов sikuda.ru");
		Возврат "";
	КонецЕсли

КонецФункции

Функция ВыбратьИзБиблиотеки() Экспорт 
	HttpСоединение = Новый HTTPСоединение( "widget.sikuda.ru",,,,,5);
	script_name = "open_gallery";
	Если type_storage > 0 Тогда script_name = "open" КонецЕсли;
	HttpЗапрос = Новый HTTPЗапрос("/_"+script_name+".php?email="+online_email+"&offset="+Формат(widget_select,"ЧДЦ=; ЧН=0; ЧГ=0"));
	мОтвет = HttpСоединение.Получить(HttpЗапрос);
	Если мОтвет.КодСостояния = 200 Тогда
		СтрокаJSON = мОтвет.ПолучитьТелоКакСтроку();
		Структура = ПрочитатьJSONВСтруктуру(СтрокаJSON);
		Если Структура = Неопределено Тогда
			Если type_storage = 2 Тогда
				СтрокаJSON = ПолучитьМакет("save_as_new").ПолучитьТекст();
			Иначе
				СтрокаJSON = ПолучитьМакет("no_more_elements").ПолучитьТекст();
			КонецЕсли;
			Структура = ПрочитатьJSONВСтруктуру(СтрокаJSON);
		КонецЕсли;
		ЗагрузитьДанныеИзСтруктуры(Структура, widgets_load);
		html = НарисоватьВиджеты(widgets_load, stepsX_load, stepsY_load, Ложь);
		Возврат html;
	КонецЕсли;
	Возврат "";
КонецФункции

Функция ПолучитьДанныеВСтрокуJSON() Экспорт
	Массив = Новый Массив;
	ТаблицаВиджетов = widgets.Выгрузить();
	Для каждого Элемент Из ТаблицаВиджетов Цикл
		СтруктураСтроки = Новый Структура;
		Для каждого Колонка из ТаблицаВиджетов.Колонки цикл
			СтруктураСтроки.Вставить(Колонка.Имя, Элемент[Колонка.Имя]);
		КонецЦикла;
		Массив.Добавить(СтруктураСтроки);
	КонецЦикла;
	Структура = Новый Структура;
	Структура.Вставить("stepsX", stepsX );
	Структура.Вставить("stepsY", stepsY );
	Структура.Вставить("email", online_email);
	Структура.Вставить("online", online);
	Структура.Вставить("widgets", Массив);
	СтрокаJSON = НеФорматированныйJSON(Структура);
	Возврат СтрокаJSON;
КонецФункции

//Проверить актуальность аккаунта и оплату.
//Возращает  актуальность аккаунту и даты  
// - bad_connect = немогу соединиться
// - bad_user = нет такого e-mail. 
// - "" (пустая строка) = нет оплат.
Функция ПроверитьАктуальность() Экспорт
	Статус = "";
	HttpСоединение = Новый HTTPСоединение( "widget.sikuda.ru");
	HttpЗапрос = Новый HTTPЗапрос("/_check_wm.php?email="+online_email);
	мОтвет = HttpСоединение.Получить(HttpЗапрос);
	Если мОтвет.КодСостояния = 200 Тогда
		Статус = мОтвет.ПолучитьТелоКакСтроку();
	Иначе
		Статус = "bad_connect";
	КонецЕсли;
	Возврат Статус;
КонецФункции	

// ------------------------------------ Функции отрисовки -------------------------------------------------
Функция НарисоватьВиджеты(widgets_table, byX = 1, byY = 1, РисоватьСетку = Ложь, mode_select = Ложь)  Экспорт
	html_view = "";
	textLibs = raphaeljs;
	ВыполнитьКод1С();
	Если widgets_table.Количество() > 0 Тогда
		typeLibs = Новый Структура;
		Для каждого widget из widgets_table Цикл
			x = "(width*"+Формат(widget.left/byX,"ЧРД=.; ЧН=0")+")";	
			y = "(height*"+Формат(widget.top/byY,"ЧРД=.; ЧН=0")+")";
			w = "(width*"+Формат((widget.right-widget.left+1)/byX,"ЧРД=.; ЧН=0")+")";
			h = "(height*"+Формат((widget.bottom-widget.top+1)/byY,"ЧРД=.; ЧН=0")+")";
			type = СтрЗаменить(widget.type," ", "");
			Если НЕ typeLibs.Свойство(type) Тогда
				textLibs = textLibs + widget.codeLib;
				typeLibs.Вставить(type, Истина);
			КонецЕсли;	
			html_widget = НарисоватьОдинВиджет( widget.code1C, widget.codeDraw, x, y, w, h, widget.onServer, ,, ((widgets_table.Индекс(widget) + 1) = widget_select));
			html_view = html_view + html_widget;
		КонецЦикла;
	КонецЕсли;
	html_view = СтрЗаменить(html_pattern, "<!-- DrawWidgets -->", html_view);
	Если РисоватьСетку Тогда
		html_view = СтрЗаменить(html_view, "<!-- DrawGrid -->", НарисоватьСетку(byX , byY ));
	КонецЕсли;	
	html_view = СтрЗаменить(html_view, "<!-- CodeLibs -->", textLibs);
	
	//Выбор места для нового элемента
	Если mode_select Тогда
		w = "(width/"+Формат(byX,"ЧРД=.; ЧН=0")+")";
		h = "(height/"+Формат(byY,"ЧРД=.; ЧН=0")+")";
		code = "rect_select = paper.rect(0,0, "+w+","+h+",5).attr({stroke: 'yellow', 'stroke-width': 5});";
		html_view = СтрЗаменить(html_view, "<!-- RectSelectInit -->", code);
		code = "if(rect_select){ rect_select.transform('T'+"+w+"*Math.floor(event.clientX/"+w+")+','+"+h+"*Math.floor(event.clientY/"+h+"));}";
		html_view = СтрЗаменить(html_view, "<!-- RectSelectMove -->", code);
	КонецЕсли;	
	
	Возврат html_view;
КонецФункции

Функция НарисоватьСетку( byX=1, byY=1 ) 
    СтрокаКода = "
	| for(var i=1; i<[byX]; i++){
	|     var x1 = i*width/ [byX];
	|     paper.path('M '+x1+','+0+'L '+x1+','+height).attr( {stroke: 'gray', 'stroke-width':'1px'}); 
	| }
	| for(var i=1; i<[byY]; i++){
	|     var y1 = i*height/ [byY];
	|     paper.path('M 0,'+y1+'L '+width+','+y1).attr( {stroke: 'gray', 'stroke-width':'1px'}); 
	| }
	| ";
	СтрокаКода = СтрЗаменить(СтрокаКода, "[byX]", Формат(byX,"ЧГ=0"));
	СтрокаКода = СтрЗаменить(СтрокаКода, "[byY]", Формат(byY,"ЧГ=0"));
	Возврат СтрокаКода;
КонецФункции

Функция НарисоватьОдинВиджет(code1C, codeDraw, x="0", y="0", w="(width)", h="(height)", onServer = false, singleView= false, libs="", fSelect = false) Экспорт
	html_widget = codeDraw;
	html_widget = СтрЗаменить(html_widget, "[x]", x);
	html_widget = СтрЗаменить(html_widget, "[y]", y);
	html_widget = СтрЗаменить(html_widget, "[w]", w);
	html_widget = СтрЗаменить(html_widget, "[h]", h);
	Если onServer = Истина Тогда
		//НаСервере
		html_widget = ВыполнитьКод1СНаСервере(code1C, html_widget);
	Иначе 	
		//НаКлиенте
		html_widget = ВыполнитьКод1СНаКлиенте(code1C, html_widget);	
	КонецЕсли;
	Если fSelect Тогда
		html_widget = html_widget + "rect_select = paper.rect("+x+","+y+", "+w+","+h+",5).attr({stroke: 'yellow', 'stroke-width': 5});";
	КонецЕсли;	
	Если singleView Тогда
		html_widget = СтрЗаменить(html_pattern, "<!-- DrawWidgets -->", html_widget);
		html_widget = СтрЗаменить(html_widget, "<!-- CodeLibs -->", raphaeljs+libs);
	КонецЕсли;	
	Возврат html_widget;
КонецФункции

Процедура ВыполнитьКод1С()
    Выполнить(code1C);	
КонецПроцедуры	

Функция ВыполнитьКод1СНаСервере(code1C, html_widget)
	Перем СтрЗначение;
	
	Сообщение = Новый СообщениеПользователю;
	Результат = Новый Структура();
	Результат.Вставить("font", ПолучитьЗначенияПараметровПоУмолчанию("font"));
	Результат.Вставить("anchor", ПолучитьЗначенияПараметровПоУмолчанию("anchor"));
	Попытка
		Выполнить(code1C);
	Исключение
		Сообщение.Текст = ОписаниеОшибки();
		Сообщение.Сообщить();
	КонецПопытки;
	Для каждого параметрКода Из Результат Цикл
		html_widget = СтрЗаменить(html_widget, "["+ПараметрКода.Ключ+"]", ПараметрКода.Значение);
	КонецЦикла;	
	Возврат html_widget;	
КонецФункции

Функция ВыполнитьКод1СНаКлиенте(code1C, html_widget)
	Перем СтрЗначение;
	
	Сообщение = Новый СообщениеПользователю;
	Результат = Новый Структура();
	Результат.Вставить("font", ПолучитьЗначенияПараметровПоУмолчанию("font"));
	Результат.Вставить("anchor", ПолучитьЗначенияПараметровПоУмолчанию("anchor"));
	Попытка
		Выполнить(code1C);
	Исключение
		Сообщение.Текст = ОписаниеОшибки();
		Сообщение.Сообщить();
	КонецПопытки;
	Для каждого параметрКода Из Результат Цикл
		html_widget = СтрЗаменить(html_widget, "["+ПараметрКода.Ключ+"]", ПараметрКода.Значение);
	КонецЦикла;	
	Возврат html_widget;
КонецФункции

//Служебные функции
Функция ПолучитьСтруктуруПараметров(code1C)
	ПараметрыКода = Новый Структура;
	НомерСимвола = 1;
	ПолученПараметр = Ложь;
	Параметр = "";
	ДлинаСтроки = стрДлина(code1C);
	Пока НомерСимвола <= ДлинаСтроки Цикл
		Символ = Сред(code1C, НомерСимвола, 1);
		Если Символ = "[" Тогда
			ПолученПараметр = Истина;
		ИначеЕсли Символ = "]" Тогда
			ПолученПараметр = Ложь;
			Если СокрЛП(Параметр) <> "" Тогда
				ПараметрыКода.Вставить(Параметр,"");
				Параметр  = "";
			КонецЕсли;	
		Иначе	
			Если ПолученПараметр Тогда
				Параметр = Параметр + Символ;
			КонецЕсли;	
		КонецЕсли;	
		НомерСимвола = НомерСимвола + 1;
	КонецЦикла;	
	Возврат ПараметрыКода; 
КонецФункции

Функция ПолучитьЗначенияПараметровПоУмолчанию(Ключ)
	Если Ключ = "font" Тогда
		Возврат "Courier New, Tahoma";
	ИначеЕсли Ключ = "anchor" Тогда
		Возврат "middle";
	Иначе
		Возврат "";
	КонецЕсли;	
КонецФункции

//#Область JSON

//JSON simple ------------------------------------------------------------------
//http://infostart.ru/public/61194/

Функция ПрочитатьJSONВСтруктуру(СтрJSON) Экспорт 
	Перем Значение;
	
	Если ПолучитьЗначениеJSON(СтрJSON,Значение)=0 Тогда
		Возврат Значение;
	КонецЕсли;
	Возврат Неопределено;
КонецФункции

//В функции конструкции условий расставлены по частоте их использования.
//Если кому нибудь удастся более оптимально (в смысле быстродействия) написать,
//то просьба сообщить мне на bigb.forum@gmail.com
Функция НеФорматированныйJSON(Значение) Экспорт
	Разделитель="";
	
	ТипЗн=ТипЗнч(Значение);

	Если ТипЗн=Тип("Строка") Тогда
		Стр=""""+Экранировать(Значение)+""""

	ИначеЕсли ТипЗн=Тип("Число") ИЛИ ТипЗнч(Значение)=Тип("Булево") Тогда
		Стр=XMLСтрока(Значение)

	ИначеЕсли ТипЗн=Тип("Дата") Тогда
		Стр=""""+?(ЗначениеЗаполнено(Значение),XMLСтрока(Значение),"")+""""

	ИначеЕсли ТипЗн=Тип("Структура") ИЛИ ТипЗн=Тип("Соответствие") Тогда
		Стр="{";
		Для Каждого Параметр Из Значение Цикл
			Стр=Стр+Разделитель+Символы.ПС+""""+Параметр.Ключ+""":"+НеФорматированныйJSON(Параметр.Значение);
			Разделитель=","
		КонецЦикла;
		Стр=Стр+Символы.ПС+"}";

	ИначеЕсли ТипЗн=Тип("Массив") Тогда
		Стр="[";
		Для Каждого Элемент Из Значение Цикл
			Стр=Стр+Разделитель+Символы.ПС+НеФорматированныйJSON(Элемент);
			Разделитель=","
		КонецЦикла;
		Стр=Стр+Символы.ПС+"]";

	ИначеЕсли ТипЗн=Тип("ТаблицаЗначений") Тогда
		Колонки=Значение.Колонки;
		Массив=Новый Массив;
		Для Каждого СтрокаТЗ Из Значение Цикл
			Структура=Новый Структура;
			Для Каждого Колонка Из Колонки Цикл
				Структура.Вставить(Колонка.Имя,СтрокаТЗ[Колонка.Имя])
			КонецЦикла;
			Массив.Добавить(Структура);
		КонецЦикла;
		Стр=НеФорматированныйJSON(Массив)

	ИначеЕсли Значение=Неопределено Тогда
		Стр="null"

	Иначе
		Стр=""""+Экранировать(Значение)+""""
	КонецЕсли;

	Возврат Стр
КонецФункции

//Экранирует недопустимые символы
Функция Экранировать(Стр)
	Х=СтрЗаменить(Стр,"\","\\");
	Х=СтрЗаменить(Х,"""","\""");
	Х=СтрЗаменить(Х,"/","\/"); 
	Х=СтрЗаменить(Х,Символ(8),"\b");
	Х=СтрЗаменить(Х,Символы.ПФ,"\f");
	Х=СтрЗаменить(Х,Символы.ПС,"\n");
	Х=СтрЗаменить(Х,Символы.ВК,"\r");
	Х=СтрЗаменить(Х,Символы.ВТаб,"\t");
	Возврат Х
КонецФункции

Функция ПолучитьЗначениеJSON(СтрJSON,Значение,Позиция=1,Ключ="")
	Перем Кавычка;

	ЗначениеВСтроке="";
	Кавычек=0;
	Комментарий=Ложь;
	Строка=Ложь;

	Пока Позиция<=СтрДлина(СтрJSON) Цикл
		ХХ=Сред(СтрJSON,Позиция,2);
		Х=Лев(ХХ,1);
		Позиция=Позиция+1;

		Если Х>" " ИЛИ Строка Тогда //Отсекаем всякий хлам

			Если Комментарий Тогда
				//Это комментарий. Крутимся в цикле пока не встретится конец комментария
				Если ХХ="*/" Тогда
					//Комментарий закончился
					Комментарий=Ложь;
					Позиция=Позиция+1;
				КонецЕсли;

			ИначеЕсли Х="\" Тогда
				Позиция=Позиция+1;
				ХХ=ВРег(ХХ);
				Если ХХ="\""" Тогда ЗначениеВСтроке=ЗначениеВСтроке+"""";
				ИначеЕсли ХХ="\\" Тогда ЗначениеВСтроке=ЗначениеВСтроке+"\";
				ИначеЕсли ХХ="\/" Тогда ЗначениеВСтроке=ЗначениеВСтроке+"/";
				ИначеЕсли ХХ="\B" Тогда ЗначениеВСтроке=ЗначениеВСтроке+Символ(8);
				ИначеЕсли ХХ="\F" Тогда ЗначениеВСтроке=ЗначениеВСтроке+Символы.ПФ; //перевод формы (страницы)
				ИначеЕсли ХХ="\N" Тогда ЗначениеВСтроке=ЗначениеВСтроке+Символы.ПС; //перевод строки
				ИначеЕсли ХХ="\R" Тогда ЗначениеВСтроке=ЗначениеВСтроке+Символы.ВК; //возврат каретки
				ИначеЕсли ХХ="\T" Тогда ЗначениеВСтроке=ЗначениеВСтроке+Символы.ВТаб; //символ вертикальной табуляции
				ИначеЕсли ХХ="\U" Тогда
					ЗначениеВСтроке=ЗначениеВСтроке+Символ(Hex2Число(Сред(СтрJSON,Позиция,4))); //шестнадцатиричное число
					Позиция=Позиция+4
				КонецЕсли;

			ИначеЕсли Строка Тогда
				//Если строка не закончилась - то пропускаем управляющие символы
				Если Х=Кавычка Тогда
					//Закончилась строка
					Строка=Ложь;
					Кавычек=Кавычек+1;
				Иначе
					ЗначениеВСтроке=ЗначениеВСтроке+Х;
				КонецЕсли;

			ИначеЕсли ХХ="/*" Тогда
				//Начался комментарий
				Комментарий=Истина;
				Позиция=Позиция+1;

			ИначеЕсли Найти("""'{}[]:,",Х)>0 Тогда
				Если Х="""" ИЛИ Х="'" Тогда
					//Началась строка
					//Строка - коллекция нуля или больше символов Unicode, заключенная в
					//двойные кавычки, используя "\" в качестве символа экранирования.
					//Символ представляется как односимвольная строка.
					//Похожий синтаксис используется в C и Java.
					Строка=Истина;
					Кавычка=Х;
					Кавычек=Кавычек+1;

				ИначеЕсли Х="{" Тогда
					//Начался объект
					//Объект - неупорядоченный набор пар ключ/значение.
					//Объект начинается с "{" и заканчивается "}".
					//Каждое имя сопровождается ":", пары ключ/значение разделяются ",".
					Объект=Новый Структура; //Соответствие;
					//Объект=Новый Структура;
					Пока Истина Цикл
						//Получим ключ и значение
						Ключ="";
						Режим=ПолучитьЗначениеJSON(СтрJSON,Значение,Позиция,Ключ);
						//0 - есть значение и не конец объекта (запятая)
						//1 - есть значение и конец объекта
						//2 - нет значения и не конец объекта (запятая)
						//3 - нет значения и конец объекта
						Если Режим=0 Тогда
							Объект.Вставить(Ключ,Значение);
						ИначеЕсли Режим=1 Тогда
							Объект.Вставить(Ключ,Значение);
							Прервать
						ИначеЕсли Режим=3 Тогда
							Прервать
						КонецЕсли;
					КонецЦикла;
					Значение=Объект;
					Возврат 0

				ИначеЕсли Х="[" Тогда
					//Начался массив
					//Массив - упорядоченная коллекция значений.
					//Массив начинается с "[" и заканчивается "]".
					//Значения разделены ",".
					Массив=Новый Массив;
					Пока Истина Цикл
						Режим=ПолучитьЗначениеJSON(СтрJSON,Значение,Позиция);
						//0 - есть значение и не конец массива (запятая)
						//1 - есть значение и конец массива
						//2 - нет значения и не конец массива (запятая)
						//3 - нет значения и конец массива
						Если Режим=0 Тогда
							Массив.Добавить(Значение);
						ИначеЕсли Режим=1 Тогда
							Массив.Добавить(Значение);
							Прервать
						ИначеЕсли Режим=3 Тогда
							Прервать
						КонецЕсли;
					КонецЦикла;
					Значение=Массив;
					Возврат 0

				ИначеЕсли Х="]" ИЛИ Х="}" Тогда
					//Закончился массив/объект
					Если ЗначениеВСтроке="" И Кавычек=0 Тогда
						Возврат 3 //нет значения и конец массива/объекта
					Иначе
						Значение=ПолучитьЗначениеИзСтроки(ЗначениеВСтроке,Кавычек);
						Возврат 1 //есть значение и конец массива/объекта
					КонецЕсли;

				ИначеЕсли Х=":" Тогда
					Ключ=ЗначениеВСтроке;
					Возврат ПолучитьЗначениеJSON(СтрJSON,Значение,Позиция);

				Иначе
					// запятая
					Прервать
				КонецЕсли;

			Иначе
				ЗначениеВСтроке=ЗначениеВСтроке+Х;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Если Кавычек>0 Тогда
		Значение=ЗначениеВКавычках(ЗначениеВСтроке);
	Иначе
		Если ЗначениеВСтроке="" Тогда
			Возврат 2
		Иначе
			Значение=ЗначениеБезКавычек(ЗначениеВСтроке)
		КонецЕсли;
	КонецЕсли;
	Возврат 0
КонецФункции

Функция Hex2Число(Hex) 
	Стр=ВРег(СокрЛП(Hex));
	Dec=0;
	Для Х=1 По СтрДлина(Стр) Цикл
		Dec=Dec+Найти("123456789ABCDEF",Сред(Стр,Х,1))*Pow(16,СтрДлина(Стр)-Х)
	КонецЦикла;
	Возврат Dec
КонецФункции

Функция ПолучитьЗначениеИзСтроки(ЗначениеВСтроке,Кавычек)
	Если Кавычек>0 Тогда
		Возврат ЗначениеВКавычках(ЗначениеВСтроке)
	ИначеЕсли ЗначениеВСтроке="" Тогда
		Возврат Неопределено
	КонецЕсли;
	Возврат ЗначениеБезКавычек(ЗначениеВСтроке)
КонецФункции

Функция ЗначениеВКавычках(ЗначениеВСтроке)
	//Это или строка или дата.
	//Дата пока не обрабатывается (потом надо дописать)
	//Пока всегда возвращаем просто строку
	Возврат ЗначениеВСтроке
КонецФункции

Функция ЗначениеБезКавычек(ЗначениеВСтроке)
	//Это число, булево или null.
	//Хотя здесь могут быть и строки. Например: {Code:123}
	Стр=ВРег(ЗначениеВСтроке);
	Если Стр="TRUE" Тогда Возврат Истина
	ИначеЕсли Стр="FALSE" Тогда Возврат Ложь
	ИначеЕсли Стр="NULL" Тогда Возврат Неопределено
	КонецЕсли;

	//Пробежимся по предполагаемому "числу"
	Экспонента=Ложь;
	ХХ=" ";
	Для Индекс=1 По СтрДлина(Стр) Цикл
		Х=Сред(Стр,Индекс,1);
		Если Найти("0123456789.+-",Х) Тогда
			ХХ=ХХ+Х
		ИначеЕсли Х="E" Тогда
			Экспонента=Истина;
			УУ=XMLЗначение(Тип("Число"),ХХ);
			ХХ=" ";
		Иначе
			Возврат ЗначениеВСтроке //Это точно не число, а строка
		КонецЕсли;
	КонецЦикла;

	ХХ=XMLЗначение(Тип("Число"),ХХ);
	Если Экспонента Тогда
		ХХ=УУ*Pow(10,ХХ)
	КонецЕсли;

	Возврат ХХ
КонецФункции

//-------------------------------------------------------------------------------
//#КонецОбласти

	
	
