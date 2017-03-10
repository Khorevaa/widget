﻿// ------------------------------------- SelfUpdate ----------------------------------------------------------------

&НаКлиенте	
Процедура ПроверитьНаличиеОбновления() Экспорт
	#Если ВебКлиент Тогда
		Возврат;
	#Иначе	
		HttpСоединение = Новый HTTPСоединение(srv);
		HttpЗапрос = Новый HTTPЗапрос(res);
		Попытка
			ИмяВремФайла = ПолучитьИмяВременногоФайла("epf");
			мОтвет = HttpСоединение.Получить(HttpЗапрос, ИмяВремФайла);
			Если мОтвет.КодСостояния <> 200 Тогда
				Статус = "bad_connect";
			КонецЕсли;
		Исключение
			Статус = "bad_connect";
		КонецПопытки;
		Если Статус = "bad_connect" Тогда
			ПоказатьПредупреждение(,НСтр("ru = 'Не могу скачать обработку!'; en = 'Bad internet connection!'"), 10);
			Возврат;
		КонецЕсли;
		ДанныеCтарые = "";
		ДанныеНовые = Новый ДвоичныеДанные(ИмяВремФайла);
		Если Лев(file,5) = "e1cib" Тогда
			ДанныеСтарые = ПолучитьСтарыеДанные();
			Если ДанныеСтарые = Неопределено Тогда
				ДанныеСтарые = ДанныеНовые;
			КонецЕсли;	
		Иначе
			ДанныеСтарые = Новый ДвоичныеДанные(file);
		КонецЕсли;
		Если ДанныеСтарые <> ДанныеНовые Тогда
			ОповещениеОбновления = Новый ОписаниеОповещения("ОбновитьОбработку", ЭтотОбъект); 
			ПоказатьВопрос(ОповещениеОбновления, "Обновить обработку?", РежимДиалогаВопрос.ДаНет,10,КодВозвратаДиалога.Да,"Действие");
		КонецЕсли;	
	#КонецЕсли
КонецПроцедуры

&НаСервере
Функция ПолучитьСтарыеДанные()
	ТекОбъект = РеквизитФормыВЗначение("Объект");
	Если Метаданные.Справочники.Найти("ДополнительныеОтчетыИОбработки") <> Неопределено Тогда
		СсылкаНаОбработку = Справочники.ДополнительныеОтчетыИОбработки.НайтиПоРеквизиту("ИмяОбъекта", ТекОбъект.Метаданные().Имя);
		Если НЕ СсылкаНаОбработку.Пустая() Тогда
			Возврат СсылкаНаОбработку.ХранилищеОбработки.Получить();
		КонецЕсли;
	КонецЕсли;	
	Возврат Неопределено;
КонецФункции

&НаКлиенте
Процедура ОбновитьОбработку(Результат, ДопПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		
		Если file = "" Тогда
			Возврат;
		КонецЕсли;	
		
		Если Лев( file,5) = "e1cib" Тогда
			Данные = Новый ДвоичныеДанные(ИмяВремФайла);
			Если ЗаписатьВнешниюОбработкуВБазу(Данные) Тогда
				ЭтаФорма.Закрыть();
			КонецЕсли;	
			Возврат;
		Иначе
			Оповещение = Новый ОписаниеОповещения( "ОбработкаПомеремещениеФайла", ЭтотОбъект);
			НачатьПеремещениеФайла(Оповещение, ИмяВремФайла, file); 
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаПомеремещениеФайла( ПеремещаемыйФайл, ДопПарамеры) Экспорт
	ЭтаФорма.Закрыть();
	Оповещение = Новый ОписаниеОповещения("ОбработкаПомещенияФайла", ЭтотОбъект, ДопПарамеры);
	НачатьПомещениеФайла(Оповещение, , file, Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаПомещенияФайла(Результат, Адрес, ВыбФайл, ДопПараметры) Экспорт
	Если Результат Тогда
		Режим = РежимДиалогаВопрос.ДаНет;
		Оповещение = Новый ОписаниеОповещения("ОповещениеПереоткрытияФормы", ЭтаФорма, Адрес); 
		ПоказатьВопрос(Оповещение, "Переоткрыть форму", Режим, 0 );
	КонецЕсли;
КонецПроцедуры

//Иногда при переокрытии формы программа вылетает, поэтому спрашиваем.
&НаКлиенте
Процедура ОповещениеПереоткрытияФормы(Результат, Адрес) Экспорт
	Если Результат = КодВозвратаДиалога.Да Тогда
		ИмяОбработки = ПодключитьНаСервере(Адрес);
		ОткрытьФорму("ВнешняяОбработка."+ ИмяОбработки +".Форма");
	КонецЕсли;	
КонецПроцедуры


&НаСервере
Функция ПодключитьНаСервере(адрес)
	Возврат ВнешниеОбработки.Подключить(Адрес);	
КонецФункции	

&НаСервере
Функция ЗаписатьВнешниюОбработкуВБазу( Данные )
	Результат = Ложь;
	Если Метаданные.Справочники.Найти("ДополнительныеОтчетыИОбработки") <> Неопределено Тогда
		СсылкаНаОбработку = Справочники.ДополнительныеОтчетыИОбработки.НайтиПоРеквизиту("ИмяОбъекта", "SeftUpdateManage");
		Если НЕ СсылкаНаОбработку.Пустая() Тогда
			ВнешийОбъект = СсылкаНаОбработку.ПолучитьОбъект();
			Хранилище = Новый ХранилищеЗначения(Данные);
			ВнешийОбъект.ХранилищеОбработки = Хранилище;
			ВнешийОбъект.Записать();
			Результат = Истина;
		КонецЕсли;
	КонецЕсли;	
	Возврат Результат;	
КонецФункции

// -----------------------------------------------------------------------------------------------------------------

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ТекОбъект = РеквизитФормыВЗначение("Объект");
	html_pattern = ТекОбъект.ПолучитьМакет("html").ПолучитьТекст();
	svgjs = ТекОбъект.ПолучитьМакет("svgjs").ПолучитьТекст();
	ЗагрузитьЭлементыИзМакета();
	Если НЕ ЗначениеЗаполнено(Значения) Тогда
		Значения = Новый Структура(); 
	КонецЕсли;
	srv = "widget.sikuda.ru";
	res = "/wp-content/uploads/dashboardManage.epf";
	ТекОбъект = РеквизитФормыВЗначение("Объект");
	ЭтаФорма.file = ТекОбъект.ИспользуемоеИмяФайла;
КонецПроцедуры

#Область ОсновныеФункцииОтрисовки

//Выполним основной код для заполнения структуры "Значения".
&НаСервере
Процедура ВыполнитьКод1С()
    Выполнить(code1C);	
КонецПроцедуры	

&НаКлиенте
Функция НарисоватьВиджеты(widgets_table, byX = 1, byY = 1, РисоватьСетку = Ложь)  Экспорт
	html_view = "";
	textLibs = svgjs;
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
			html_widget = НарисоватьОдинВиджет( widget.code1C, widget.codeDraw, x, y, w, h, widget.onServer, ,widget.codeLib, ((widgets_table.Индекс(widget) + 1) = widget_select));
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
		code = "rect_select = paper.rect("+w+","+h+").style('fill:none;stroke:yellow;stroke-width:5');";
		html_view = СтрЗаменить(html_view, "<!-- RectSelectInit -->", code);
		code = "if(rect_select){ rect_select.move("+w+"*Math.floor(event.clientX/"+w+"),"+h+"*Math.floor(event.clientY/"+h+")); }";
		html_view = СтрЗаменить(html_view, "<!-- RectSelectMove -->", code);
	КонецЕсли;
	
	Возврат html_view;
КонецФункции

&НаКлиенте
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

&НаКлиенте
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
		//html_widget = html_widget + "rect_select = paper.rect("+x+","+y+", "+w+","+h+",5).attr({stroke: 'yellow', 'stroke-width': 5});";
		html_widget = html_widget + "rect_select = paper.rect("+w+","+h+").move("+x+","+y+").style('fill:none;stroke:yellow;stroke-width:5');";
	КонецЕсли;	
	Если singleView Тогда
		html_widget = СтрЗаменить(html_pattern, "<!-- DrawWidgets -->", html_widget);
		html_widget = СтрЗаменить(html_widget, "<!-- CodeLibs -->", svgjs+libs);
	КонецЕсли;	
	Возврат html_widget;
КонецФункции

&НаСервере
Функция ВыполнитьКод1СНаСервере(code1C, html_widget)
	Перем СтрЗначение;
	
	Сообщение = Новый СообщениеПользователю;
	Результат = Новый Структура();
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

&НаКлиенте
Функция ВыполнитьКод1СНаКлиенте(code1C, html_widget)
	Перем СтрЗначение;
	
	Сообщение = Новый СообщениеПользователю;
	Результат = Новый Структура();
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
&НаКлиентеНаСервереБезКонтекста
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

#КонецОбласти

&НаКлиенте
Процедура onlineПриИзменении(Элемент)
	кнпПроверкаНажатие(Элемент);
КонецПроцедуры

&НаКлиенте
Процедура online_emailПриИзменении(Элемент)
	кнпПроверкаНажатие(Элемент);	
КонецПроцедуры

&НаКлиенте
//Проверка состояния на сайте
Процедура кнпПроверкаНажатие(Элемент)
	Если online И ЗначениеЗаполнено(online_email) Тогда
		Режим = РежимДиалогаВопрос.ДаНет;
		#Если ВебКлиент Тогда
			Статус = ПроверитьАктуальностьСервер(online_email);
		#Иначе
			Статус = ПроверитьАктуальность(online_email);
		#КонецЕсли
		Если Статус = "bad_connect" Тогда
			online_status = "Нет связи";
			Элементы.group_online.ЦветФона = WebЦвета.Красный;
		    Элементы.online.Подсказка = "Нет соединения с интернетом";
		ИначеЕсли Статус = "bad_user" Тогда
			Элементы.online.Подсказка = "Нет пользователя c таким e-mail на сайте sikuda.ru";
			Элементы.group_online.ЦветФона = WebЦвета.Желтый;
			Оповещение = Новый ОписаниеОповещения("ОповещениеРегистрации", ЭтаФорма); 
			ПоказатьВопрос(Оповещение, Элементы.online_status.Заголовок + Символы.ПС + "Перейти к регистрации пользователя", Режим, 0 );
		Иначе
			Элементы.online.Подсказка = "";
			Элементы.group_online.ЦветФона = WebЦвета.Зеленый;
		КонецЕсли;
	Иначе
		Если НЕ ЗначениеЗаполнено(online_email) Тогда
			ПоказатьПредупреждение(,НСтр("ru = 'Пожалуйста, заполните e-mail "+Символы.ПС+" для работы!'; en = 'Please fill e-mail!'"), 10);
		КонецЕсли;	
		online_status = "";
		Элементы.group_online.ЦветФона = Элементы.online_email.ЦветФона;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОповещениеРегистрации(Результат, Параметры) Экспорт
	Если Результат = КодВозвратаДиалога.Да Тогда
		ПерейтиПоНавигационнойСсылке("http://widget.sikuda.ru/wp-login.php?action=register&user_email="+online_email+"&user_login="+online_email);
	КонецЕсли;	
КонецПроцедуры


&НаСервере
Функция ПроверитьАктуальностьСервер(online_email)
	Возврат ПроверитьАктуальность(online_email);	
КонецФункции

&НаКлиенте
Функция ПроверитьАктуальностьКлиент(online_email)
	Возврат ПроверитьАктуальность(online_email);	
КонецФункции	

//Проверить актуальность аккаунта и оплату.
//Возращает  актуальность аккаунту и даты  
// - bad_connect = немогу соединиться
// - bad_user = нет такого e-mail. 
// - "" (пустая строка) = нормально.
// - 2016-01-20 = конец периода.
&НаКлиентеНаСервереБезКонтекста
Функция ПроверитьАктуальность(online_email) 
	Статус = "";
	HttpСоединение = Новый HTTPСоединение("widget.sikuda.ru");
	HttpЗапрос = Новый HTTPЗапрос("/_check_wm.php?email="+online_email);
	Попытка
		мОтвет = HttpСоединение.Получить(HttpЗапрос);
		Если мОтвет.КодСостояния = 200 Тогда
			Статус = мОтвет.ПолучитьТелоКакСтроку();
		Иначе
			Статус = "bad_connect";
		КонецЕсли;
	Исключение
		Статус = "bad_connect";
	КонецПопытки;
	Возврат Статус;
КонецФункции	

//Перейти к настройке
&НаКлиенте
Процедура НастройкаОткрыть(Команда)
	stepsX_Settings = stepsX;
	stepsY_Settings = stepsY;
	widgets_settings.Очистить();
	Для каждого widget из widgets Цикл
		set_widget = widgets_settings.Добавить();
		ЗаполнитьЗначенияСвойств(set_widget, widget);
	КонецЦикла;
	Элементы.View.Видимость = Ложь;
	Элементы.Settings.Видимость = Истина;
	ОбновитьОтображение( Истина );
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	ОбновитьОтображение(Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьОтображение( РежимНастройки = Ложь )
	Если РежимНастройки Тогда
		html = НарисоватьВиджеты(widgets_settings, stepsX_Settings, stepsY_Settings,Истина);
		Заголовок = "НАСТРОЙКА. Панель показателей.";
	Иначе
		html = НарисоватьВиджеты(widgets, stepsX, stepsY);
		Заголовок = "Панель показателей.";
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Элементы.View.Видимость = Истина;
	Элементы.Settings.Видимость = Ложь;
	Элементы.Set_one.Видимость = Ложь;
	Элементы.Code1C.Видимость = Ложь;
	Элементы.new_widgets.Видимость = Ложь;
	Если stepsX = 0 Тогда stepsX = 3; КонецЕсли;
	Если stepsY = 0 Тогда stepsY = 3; КонецЕсли;
	ПодключитьОбработчикОжидания("ПроверитьНаличиеОбновления",1,Истина);
	ОбновитьОтображение();
КонецПроцедуры

&НаКлиенте
Процедура ВводНастроекЗавершение(Результат, Параметры) Экспорт
	Если Результат <> Неопределено Тогда
		online_emaile_email = Результат.email;
		online = Результат.online;
		ИнтервалОбновления = Результат.ИнтервалОбновления;
		КоличествоБлоковПоВертикали = Результат.КоличествоБлоковПоВертикали;
		КоличествоБлоковПоГоризонтали = Результат.КоличествоБлоковПоГоризонтали;
		Если Результат.Свойство("ТаблицаВиджетов") Тогда
			widgets.Очистить();
			Для каждого строкаВиджета из Результат.ТаблицаВиджетов Цикл
				widget = widgets.Добавить();
				ЗаполнитьЗначенияСвойств(widget, строкаВиджета);
			КонецЦикла;
		КонецЕсли;
		Если ИнтервалОбновления > 0 Тогда
			ПодключитьОбработчикОжидания("ОбновитьОтображение", ИнтервалОбновления, Ложь);
		КонецЕсли;
		ОбновитьОтображение();
	КонецЕсли;	
КонецПроцедуры	

// ---------------------------- Процедуры Выбора ----------------------- 
&НаКлиенте
Функция ПолучитьНаКоординатыжатогоВиджета(ДанныеСобытия, byX, byY) Экспорт
	Координаты = Новый Структура;
	Координаты.Вставить("left", Цел(byX * ДанныеСобытия.Event.clientX / ЭтотОбъект.HTMLWidth));
	Координаты.Вставить("top", Цел(byY * ДанныеСобытия.Event.clientY / ЭтотОбъект.HTMLHeight));
	Возврат Координаты;
КонецФункции

&НаКлиенте
Функция ПолучитьВиджетНажатия(ДанныеСобытия, byX, byY, widgets_table)
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

//Нажатие - выполнение расшифровки
&НаКлиенте
Процедура htmlПриНажатии(Элемент, ДанныеСобытия, СтандартнаяОбработка)
	widget = ПолучитьВиджетНажатия(ДанныеСобытия, stepsX, stepsY, widgets);
	Если widget <> Неопределено Тогда
		КодРасшифровки = widget.code1Click;
		Если ЗначениеЗаполнено(КодРасшифровки) Тогда
			СтандартнаяОбработка = Ложь;
			#Если ВебКлиент Тогда
				ВыполнитьКод1СНаСервере(КодРасшифровки, "");
			#Иначе
				ВыполнитьКод1СНаКлиенте(КодРасшифровки, "");		
			#КонецЕсли
			ОбновитьОтображение();
		КонецЕсли;	
	КонецЕсли;	
КонецПроцедуры

//Нажатие - настройка виджета или вставка нового
&НаКлиенте
Процедура html_settingsПриНажатии(Элемент, ДанныеСобытия, СтандартнаяОбработка)
	
	//Вставка нового элемента
	Если mode_select Тогда
		Координаты = ПолучитьНаКоординатыжатогоВиджета(ДанныеСобытия, stepsX_Settings, stepsY_Settings);
		Если ЗначениеЗаполнено(Координаты) Тогда
			widget = widgets_settings.Добавить();
			widget.id = Новый УникальныйИдентификатор();
			widget.type = one_type; 
			widget.left = Координаты.left;
			widget.top = Координаты.top;
			widget.right = Координаты.left;
			widget.bottom = Координаты.top;
			widget.code1C = one_code1C;
			widget.code1Click = one_code1Click;
			widget.codeDraw = one_codeDraw;
			widget.codeLib = one_codeLib;	
		КонецЕсли;	
		mode_select = Ложь;
		ОбновитьОтображение(Истина);
		Возврат;
	КонецЕсли;	
	
	//Редактирование существующего
	widget = ПолучитьВиджетНажатия(ДанныеСобытия, stepsX_Settings, stepsY_Settings, widgets_settings);
	Если widget <> Неопределено Тогда
		//Настройка виджета
		one_id = widget.id; //ПолучитьИдентификатор();
		one_type = widget.type;
		one_code1C = widget.code1C;
		one_codeDraw = widget.codeDraw;
		one_onServer = widget.onServer;
		one_code1Click = widget.code1Click;
		one_codeLib = widget.codeLib;
		Элементы.Set_one.Видимость = Истина;
	    Элементы.Settings.Видимость = Ложь;
		Элемент_Выполнить(Неопределено);
	КонецЕсли	
КонецПроцедуры

&НаКлиенте
Функция ВвестиЗначение1С(Имя, Подсказка) Экспорт
	Значение = Значения[Имя];
	ДопПараметры = Новый Структура("Имя", Имя);
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработкаВводаЗначения", ЭтаФорма, ДопПараметры);
	ПоказатьВводЗначения(ОписаниеОповещения, Значение, Подсказка);
КонецФункции

&НаКлиенте
Процедура ОбработкаВводаЗначения(Результат, ДопПараметры) Экспорт
	Если Результат <> Неопределено Тогда
		Значения.Вставить(ДопПараметры.Имя, Результат);
		ОбновитьОтображение();
	КонецЕсли;	
КонецПроцедуры

// ------------------------------- Settings -------------------------------------

//Применить новый настройки 
&НаКлиенте
Процедура НастройкаПрименить(Команда)
	stepsX = stepsX_Settings;
	stepsY = stepsY_Settings;
	widgets.Очистить();
	Для каждого set_widget из widgets_settings Цикл
		widget = widgets.Добавить();
		ЗаполнитьЗначенияСвойств(widget, set_widget);
	КонецЦикла;
	Элементы.View.Видимость = Истина;
	Элементы.Settings.Видимость = Ложь;
	widgets_settings.Очистить();
	html_settings = "";
	widget_select = 0;
	ОбновитьОтображение();
КонецПроцедуры

&НаКлиенте
Процедура Настройка_ОчиститьВсе(Команда)
	widget_select = 0;
	widgets_settings.Очистить();
	ОбновитьОтображение(Истина);
КонецПроцедуры

&НаКлиенте
Процедура НастройкаОтменить(Команда)
	widget_select = 0;
	Элементы.View.Видимость = Истина;
	Элементы.Settings.Видимость = Ложь;
КонецПроцедуры

#Область ЭкпортДанных

&НаКлиенте
Процедура ЭкспортДанных(Команда)
	Если online И ЗначениеЗаполнено(online_email) Тогда
		//Выбор экрана для сохранения
		type_storage = 2;
		mode_select = Ложь;
		Если ВыбратьИзБиблиотеки() Тогда
			Элементы.View.Видимость = Ложь;
			Элементы.new_widgets.Видимость = Истина;
			Элементы.НадписьВыбора.Заголовок = "ВЫБЕРИТЕ КАКИЕ ДАННЫЕ БУДЕТЕ ЗАМЕНЯТЬ";
			html = НарисоватьВиджеты(widgets_load, stepsX_load, stepsY_load, Ложь);
		КонецЕсли;
	Иначе
		Адрес = ЗаписатьJSONвХранилище();
		#Если ВебКлиент Тогда
			ПолучитьФайл(Адрес, "Настройки.json", Истина);
		#Иначе
			ОписаниеОповещения = Новый ОписаниеОповещения("ОбработкаСохраненияФайлов", ЭтаФорма);
			Файл = Новый ОписаниеПередаваемогоФайла("Настройки.json", Адрес);
			ПолучаемыеФайлы = Новый Массив;
			ПолучаемыеФайлы.Добавить(Файл);
			ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
			ДиалогОткрытияФайла.МножественныйВыбор = Ложь;
			НачатьПолучениеФайлов(ОписаниеОповещения,ПолучаемыеФайлы, ДиалогОткрытияФайла, Истина);
		#КонецЕсли
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаСохраненияФайлов( ПомещенныеФайлы, ДополнительныеПараметры) Экспорт 	
	Если ПомещенныеФайлы <> Неопределено Тогда
		//Сообщить("Экспорт завершен");	
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ЗаписатьJSONвХранилище()
	Массив = Новый Массив;
	ТаблицаВиджетов = widgets.Выгрузить();
	Для каждого Элемент Из ТаблицаВиджетов Цикл
		СтруктураСтроки = Новый Структура;
		Для каждого Колонка из ТаблицаВиджетов.Колонки цикл
			СтруктураСтроки.Вставить(Колонка.Имя, Элемент[Колонка.Имя]);
		КонецЦикла;
		//для совместимости с неуправляемыми приложениями
		СтруктураСтроки.Вставить("id", Строка(Элемент.id));
		Массив.Добавить(СтруктураСтроки);
	КонецЦикла;
	Структура = Новый Структура;
	Структура.Вставить("stepsX", stepsX);
	Структура.Вставить("stepsY", stepsY);
	Структура.Вставить("code1C", code1C);
	Структура.Вставить("widgets",Массив);
		
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, Структура);
	СтрокаJSON = ЗаписьJSON.Закрыть();
	Возврат ПоместитьВоВременноеХранилище(СтрокаJSON);
КонецФункции

#КонецОбласти

#Область ИмпортДанных

//Загрузка
&НаКлиенте
Процедура ИмпортДанных(Команда)
	Если online И ЗначениеЗаполнено(online_email) Тогда
		type_storage = 1; //прользовательские данные
		mode_select = Ложь;
		Если ВыбратьИзБиблиотеки() Тогда
			Элементы.View.Видимость = Ложь;
			Элементы.new_widgets.Видимость = Истина;
			Элементы.НадписьВыбора.Заголовок = "ВЫБЕРИТЕ ЭКРАН ДЛЯ ЗАГРУЗКИ";
			html = НарисоватьВиджеты(widgets_load, stepsX_load, stepsY_load, Ложь);
		КонецЕсли;
	Иначе
		ОписаниеОповещения = Новый ОписаниеОповещения("ОбработкаЗагрузкиФайлов", ЭтаФорма);
		НачатьПомещениеФайла(ОписаниеОповещения,,,Истина);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаЗагрузкиФайлов( Результат, Адрес, ВыбранноеИмяФайла, ДополнительныеПараметры) Экспорт 	
	Если Результат Тогда
		Структура = ЗагрузитьJSONизХранилища(Адрес);
		ЗагрузитьДанныеИзСтруктуры( Структура );
		ОбновитьОтображение();
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ЗагрузитьJSONизХранилища(Адрес)
	Попытка
		Данные = ПолучитьИзВременногоХранилища(Адрес);
		ИмяВременногоФайла = ПолучитьИмяВременногоФайла("json");	
		Данные.Записать(ИмяВременногоФайла);
		ЧтениеJSON = Новый ЧтениеJSON();
		ЧтениеJSON.ОткрытьФайл(ИмяВременногоФайла);
		Структура = ПрочитатьJSON(ЧтениеJSON);
		ЧтениеJSON.Закрыть();
		УдалитьФайлы(ИмяВременногоФайла);
		Возврат Структура;
	Исключение
		Возврат Неопределено
	КонецПопытки;
КонецФункции

&НаСервере
Функция ПрочитатьJSONВСтруктуру(СтрокаJSON)
	Попытка
		ЧтениеJSON = Новый ЧтениеJSON();
		ЧтениеJSON.УстановитьСтроку(СтрокаJSON);
		Структура = ПрочитатьJSON(ЧтениеJSON);
		ЧтениеJSON.Закрыть();
		Возврат Структура;	
	Исключение
		Возврат Неопределено
	КонецПопытки;
КонецФункции
	
&НаСервере
Процедура ЗагрузитьДанныеИзСтруктуры( Структура, type_to = 0 ) Экспорт
	Если ТипЗнч(Структура) = Тип("Структура") Тогда
		widgets_table = widgets;
		Значения = Новый Структура();
		Если type_to = 1 Тогда
			stepsX_widgets = 3;
			Если Структура.Свойство("stepsX") Тогда
				stepsX_widgets = Структура.stepsX; 					
			КонецЕсли;
			stepsY_widgets = 3;
			Если Структура.Свойство("stepsY") Тогда
				stepsY_widgets = Структура.stepsY; 					
			КонецЕсли;
			widgets_table = widgets_type;
		ИначеЕсли  type_to = 2 Тогда
			Если Структура.Свойство("stepsX") Тогда
				stepsX_load = Структура.stepsX; 					
			КонецЕсли;
			Если Структура.Свойство("stepsY") Тогда
				stepsY_load = Структура.stepsY; 					
			КонецЕсли;
			widgets_table = widgets_load;
		Иначе
			Если Структура.Свойство("Значения") Тогда
				Значения = Структура.Значения;
			КонецЕсли;
			Если Структура.Свойство("stepsX") Тогда
				stepsX = Структура.stepsX; 					
			КонецЕсли;
			Если Структура.Свойство("stepsY") Тогда
				stepsY = Структура.stepsY; 					
			КонецЕсли;
		КонецЕсли;
		widgets_table.Очистить();
		Если Структура.Свойство("widgets") Тогда
			Если Тип(Структура.widgets) = Тип("Массив") Тогда
				Для каждого Элемент Из Структура.widgets Цикл
					ДанныеСтроки = widgets_table.Добавить();
					ЗаполнитьЗначенияСвойств( ДанныеСтроки, Элемент);
					ДанныеСтроки.id = Новый УникальныйИдентификатор(Элемент.id)
				КонецЦикла;
			Иначе
				widgets_table.Загрузить(Структура.widgets);
			КонецЕсли;	
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Данные_ИмпортГаллерея(Команда)
	Если online И ЗначениеЗаполнено(online_email) Тогда
		type_storage = 0; //данные из галерее
		mode_select = Ложь;
		Если ВыбратьИзБиблиотеки() Тогда
			Элементы.НадписьВыбора.Заголовок = "ВЫБЕРИТЕ ЭКРАН ДЛЯ ЗАГРУЗКИ";
			html = НарисоватьВиджеты(widgets_load, stepsX_load, stepsY_load, Ложь);
			Элементы.View.Видимость = Ложь;
			Элементы.new_widgets.Видимость = Истина;
		КонецЕсли;
	Иначе
		ПоказатьПредупреждение(,НСтр("ru = 'Возможность есть только в режиме "+Символы.ПС+"соединения с интернетом!'; en = 'Select online and fill e-mail!'"), 10);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ВыбратьИзБиблиотеки() Экспорт 
	HttpСоединение = Новый HTTPСоединение( "widget.sikuda.ru",,,,,5);
	script_name = "open_gallery";
	Если type_storage > 0 Тогда script_name = "open" КонецЕсли;
	HttpЗапрос = Новый HTTPЗапрос("/_"+script_name+".php?email="+online_email+"&offset="+Формат(widget_select,"ЧДЦ=; ЧН=0; ЧГ=0"));
	мОтвет = HttpСоединение.Получить(HttpЗапрос);
	Если мОтвет.КодСостояния = 200 Тогда
		СтрокаJSON = мОтвет.ПолучитьТелоКакСтроку();
		Структура = ПрочитатьJSONВСтруктуру(СтрокаJSON);
		ТекОбъект = РеквизитФормыВЗначение("Объект");
		Если Структура = Неопределено Тогда
			Если type_storage = 2 Тогда
				СтрокаJSON = ТекОбъект.ПолучитьМакет("save_as_new").ПолучитьТекст();
			Иначе
				СтрокаJSON = ТекОбъект.ПолучитьМакет("no_more_elements").ПолучитьТекст();
			КонецЕсли;
			Структура = ПрочитатьJSONВСтруктуру(СтрокаJSON);
		КонецЕсли;
		ЗагрузитьДанныеИзСтруктуры(Структура, 2);
		Возврат Истина;
	КонецЕсли;
	Возврат Ложь;
КонецФункции

&НаСервере
Процедура ЗагрузитьЭлементыИзМакета() Экспорт
	ТекОбъект = РеквизитФормыВЗначение("Объект");
	СтрокаДанных = ТекОбъект.ПолучитьМакет("widgets_type").ПолучитьТекст();
	//Массив = ЗаполнитьМассивВиджетовНаСервере(СтрокаДанных);
	ЧтениеJSON = Новый ЧтениеJSON();
	СтрокаДанных = СтрЗаменить(СтрокаДанных, Символ(65279), ""); //Удалим BOM
	ЧтениеJSON.УстановитьСтроку(СтрокаДанных);
	//Для тестирования
	//СтрокаКодов = "";
	//Для й = 1 По СтрДлина(СтрокаДанных) Цикл
	//	СтрокаКодов = СтрокаКодов + ":" + Формат(КодСимвола(СтрокаДанных, й), "ЧГ=0") + Символы.ПС;
	//КонецЦикла;	
	Структура = ПрочитатьJSON(ЧтениеJSON);
	ЧтениеJSON.Закрыть();
	stepsX_widgets = 3;
	Если Структура.Свойство("stepsX") Тогда
		stepsX_widgets = Структура.stepsX;
	КонецЕсли;
	stepsY_widgets = 3;
	Если Структура.Свойство("stepsY") Тогда
		stepsY_widgets = Структура.stepsY;
	КонецЕсли;
	widgets_type.Очистить();
	Если Структура.Свойство("widgets") Тогда
		Массив = Структура.widgets;
		Для каждого Элемент Из Массив Цикл
			widget = widgets_type.Добавить();
			ЗаполнитьЗначенияСвойств(widget, Элемент);
		КонецЦикла;	
	КонецЕсли;
КонецПроцедуры	

#КонецОбласти

&НаКлиенте
Процедура settings_stepsXПриИзменении(Элемент)
	Если stepsX <= 0 Тогда stepsX = 1; КонецЕсли;
	ОбновитьОтображение(Истина);
КонецПроцедуры

&НаКлиенте
Процедура setings_stepsYПриИзменении(Элемент)
	Если stepsY <= 0 Тогда stepsY = 1; КонецЕсли;
	ОбновитьОтображение(Истина);
КонецПроцедуры

&НаКлиенте
Процедура кпнРазмерПозизияИзменить(Элемент)
	Если widget_select = 0 Тогда Возврат; КонецЕсли;
	строкаВиджета = widgets_settings[widget_select - 1];
	Если строкаВиджета <> Неопределено Тогда
		top = строкаВиджета.top;
		bottom = строкаВиджета.bottom;
		left = строкаВиджета.left;
		right = строкаВиджета.right;
		//Размер
		Если Элемент.Имя = "кпнРазмерВверхУвел" Тогда	
			Если (top > 0) Тогда top = top - 1; КонецЕсли;
		ИначеЕсли Элемент.Имя = "кпнРазмерВверхУм" Тогда	
			Если (top < bottom) Тогда top = top + 1; КонецЕсли;
		ИначеЕсли Элемент.Имя = "кпнРазмерНизУвел" Тогда	
			Если (bottom < (stepsY_Settings-1)) Тогда bottom = bottom + 1; КонецЕсли;
		ИначеЕсли Элемент.Имя = "кпнРазмерНизУм" Тогда	
			Если (top < bottom ) Тогда bottom = bottom - 1; КонецЕсли;
		ИначеЕсли Элемент.Имя = "кпнРазмерПравоУвел" Тогда	
			Если (right < (stepsX_Settings-1) ) Тогда right = right + 1; КонецЕсли;
		ИначеЕсли Элемент.Имя = "кпнРазмерПравоУм" Тогда		
			Если (left < right) Тогда right = right - 1; КонецЕсли;
		ИначеЕсли Элемент.Имя = "кпнРазмерЛевоУвел" Тогда	
			Если (left > 0) Тогда left = left - 1; КонецЕсли;
		ИначеЕсли Элемент.Имя = "кпнРазмерЛевоУм" Тогда	
			Если (left < right) Тогда left = left + 1; КонецЕсли;
		КонецЕсли;
		//Позиция
		Если Элемент.Имя = "кпнПозВверх" Тогда	
			Если (top > 0) Тогда top = top - 1; bottom = bottom - 1; КонецЕсли;
		ИначеЕсли Элемент.Имя = "кпнПозНиз" Тогда	
			Если (bottom < (stepsY_Settings-1)) Тогда top = top + 1; bottom = bottom + 1 КонецЕсли;
		ИначеЕсли Элемент.Имя = "кпнПозПраво" Тогда	
			Если (right < (stepsX_Settings-1) ) Тогда right = right + 1; left = left + 1; КонецЕсли;
		ИначеЕсли Элемент.Имя = "кпнПозЛево" Тогда	
			Если (left > 0) Тогда left = left - 1; right = right - 1; КонецЕсли;
		КонецЕсли;
		
		строкаВиджета.top = top; 	
		строкаВиджета.bottom = bottom;	
		строкаВиджета.left = left;	
		строкаВиджета.right = right;
		ОбновитьОтображение(Истина);
	КонецЕсли;
КонецПроцедуры

// -------------------------- set of one ---------------------------------------

&НаКлиенте
Процедура Элемент_Выполнить(Команда)
	one_html = НарисоватьОдинВиджет( one_code1C, one_codeDraw, "0", "0", "(width)", "(height)", one_onServer, True, one_codeLib);
КонецПроцедуры

&НаКлиенте
Процедура Элемент_Применить(Команда)
	Отбор = Новый Структура();
	Отбор.Вставить("id", one_id); 
	строкаВиджета = widgets_settings.НайтиСтроки(Отбор);
	Если строкаВиджета.Количество() > 0 Тогда
		строкаВиджета[0].id = one_id;
		строкаВиджета[0].type = one_type;
		строкаВиджета[0].code1C = one_code1C;
		строкаВиджета[0].codeDraw = one_codeDraw;
		строкаВиджета[0].code1Click = one_code1Click;
		строкаВиджета[0].onServer = one_onServer;
		строкаВиджета[0].codeLib = one_codeLib;
    КонецЕсли;
	Элементы.Settings.Видимость = Истина;
	Элементы.Set_one.Видимость = Ложь;
	ОбновитьОтображение( Истина );
КонецПроцедуры

&НаКлиенте
Процедура Элемент_Отмена(Команда)
	Элементы.Settings.Видимость = Истина;
	Элементы.Set_one.Видимость = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура Элемент_Удалить(Команда)
	Режим = РежимДиалогаВопрос.ДаНет;
	Оповещение = Новый ОписаниеОповещения("ОповещениеУдалениеВиджета", ЭтаФорма); 
	ПоказатьВопрос(Оповещение, "Удалить элемент", Режим, 0 );
КонецПроцедуры

&НаКлиенте
Процедура ОповещениеУдалениеВиджета(Результат, Параметры) Экспорт
	Если Результат = КодВозвратаДиалога.Да Тогда
		Отбор = Новый Структура();
		Отбор.Вставить("id", one_id); 
		строкаВиджета = widgets_settings.НайтиСтроки(Отбор);
		Если строкаВиджета.Количество() > 0 Тогда
			widgets_settings.Удалить(строкаВиджета[0]);
			Элементы.Settings.Видимость = Истина;
			Элементы.Set_one.Видимость = Ложь;
			ОбновитьОтображение(Истина);
		КонецЕсли;	
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура Элемент_Сохранить(Команда)
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура Элемент_Загрузить(Команда)
	// Вставить содержимое обработчика.
КонецПроцедуры

// ----------------------------- Code 1C -----------------------------------

&НаКлиенте
Процедура Модуль1С_Открыть(Команда)
	Элементы.Code1C.Видимость = Истина;
	Элементы.Settings.Видимость = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура Модуль1С_Закрыть(Команда)
	Элементы.Code1C.Видимость = Ложь;
	Элементы.Settings.Видимость = Истина;
	ОбновитьОтображение(Истина);
КонецПроцедуры

// ----------------------------- New Widgets --------------------------------

&НаКлиенте
Процедура ДобавитьЭлемент(Команда)
	Элементы.Settings.Видимость = Ложь;
	Элементы.new_widgets.Видимость = Истина;
	mode_select = Истина;
	html = НарисоватьВиджеты(widgets_type, stepsX_widgets, stepsY_widgets, Истина)
КонецПроцедуры

&НаКлиенте
Процедура Элемент_ОтменаДобавления(Команда)
	Если mode_select Тогда
		Элементы.Settings.Видимость = Истина;
		Элементы.new_widgets.Видимость = Ложь;
		ОбновитьОтображение(Истина);
	Иначе
		Элементы.View.Видимость = Истина;
		Элементы.new_widgets.Видимость = Ложь;
		ОбновитьОтображение(Ложь);
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура html_wigetsПриНажатии(Элемент, ДанныеСобытия, СтандартнаяОбработка)
	//Выбор отдельного виджета
	Если mode_select Тогда
		widget = ПолучитьВиджетНажатия(ДанныеСобытия, stepsX_widgets, stepsY_widgets, widgets_type);
		Если widget <> Неопределено Тогда
			one_type = widget.type; 
			one_code1C = widget.code1C;
			one_code1Click = widget.code1Click;
			one_codeDraw = widget.codeDraw;
			one_codeLib = widget.codeLib;
			//mode_select = Ложь;
			Элементы.Settings.Видимость = Истина;
			Элементы.new_widgets.Видимость = Ложь;
			ОбновитьОтображение(Истина);	
		КонецЕсли;
	Иначе
		Если type_storage = 2 Тогда //Выбор страницы для сохранения
			Если widget_select = widgets_load.Количество() Тогда //Это новая запись в Базе
				Оповещение = Новый ОписаниеОповещения("html_wigetsВыборНазвания", , Параметры);
				ПоказатьВводСтроки(Оповещение, "", "Введите имя графика для сохранения", 0, Истина);
			Иначе
				html_wigetsВыборНазвания("", Неопределено);
			КонецЕсли;
		Иначе
			stepsX = stepsX_load;
			stepsY = stepsY_load;
			ПерегрузитьИзГалереи();
		КонецЕсли;
		Элементы.View.Видимость = Истина;
		Элементы.new_widgets.Видимость = Ложь;
		ОбновитьОтображение();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПерегрузитьИзГалереи()
	widgets.Загрузить(widgets_load.Выгрузить());	
КонецПроцедуры	

&НаКлиенте
Процедура html_wigetsВыборНазвания(Строка, Параметры) Экспорт
    Если НЕ Строка = Неопределено Тогда
        HttpСоединение = Новый HTTPСоединение( "widget.sikuda.ru",,,,,5);
		HttpЗапрос = Новый HTTPЗапрос("/_save.php?email="+online_email+"&title="+Строка+"&offset="+Формат(widget_select,"ЧДЦ=; ЧН=0; ЧГ=0"));
		мОтвет = HttpСоединение.Получить(HttpЗапрос);
		Если мОтвет.КодСостояния = 200 Тогда
			СтрокаJSON = мОтвет.ПолучитьТелоКакСтроку();
			HttpЗапрос.УстановитьТелоИзСтроки(СтрокаJSON);
			мОтвет = HttpСоединение.Записать(HttpЗапрос);
		КонецЕсли;
    КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура Элемент_Выделить(Команда)
	widget_select = widget_select + 1;
	Если widget_select > widgets_settings.Количество() Тогда
		widget_select = 0;
	КонецЕсли;
	ОбновитьОтображение(Истина);
КонецПроцедуры

&НаКлиенте
Процедура Элемент_Предыдущий(Команда)
	Если widget_select = 0 Тогда
		Возврат;
	КонецЕсли;	
	widget_select = widget_select - 1;
	Если ВыбратьИзБиблиотеки() Тогда
		html = НарисоватьВиджеты(widgets_load, stepsX_load, stepsY_load, Ложь);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Элемент_Следующий(Команда)
	Если widget_select > 0 И widgets_load.Количество() = 1 Тогда
		Возврат;
	КонецЕсли;	
	widget_select = widget_select + 1;
	Если ВыбратьИзБиблиотеки() Тогда
		html = НарисоватьВиджеты(widgets_load, stepsX_load, stepsY_load, Ложь);
	КонецЕсли;		
КонецПроцедуры

&НаКлиенте
Функция ОкноБраузера( ИмяПоля )
	ДокументБраузера = Элементы[ИмяПоля].Документ;
	cm_ОкноБраузера     = ДокументБраузера.parentWindow; // IE
	Если cm_ОкноБраузера = Неопределено Тогда
		cm_ОкноБраузера = ДокументБраузера.defaultView; // Прочие браузеры
	КонецЕсли;
	Возврат cm_ОкноБраузера;
КонецФункции


&НаКлиенте
Процедура htmlДокументСформирован(Элемент)
	HTMLHeight = 1;
	HTMLWidth = 1;
	//Попытка
		ОпределитьРазмерыОкна();
	//Исключение
		//Сообщить(ОписаниеОшибки());
	//КонецПопытки	
КонецПроцедуры

&НаКлиенте
Процедура ОпределитьРазмерыОкна()
	Имя = "html";
	Если Элементы.Settings.Видимость Тогда Имя = "html_settings"; КонецЕсли;
	Если Элементы.new_widgets.Видимость Тогда Имя = "html_wigets"; КонецЕсли;
	win = ОкноБраузера(Имя);
	Если win.height = 1 Тогда
    	ПодключитьОбработчикОжидания("ОпределитьРазмерыОкна", 1, Истина);
	Иначе
		HTMLHeight = win.height;
		HTMLWidth = win.width;
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура Элемент_Выбрать(Команда)
	Если type_storage = 2 Тогда //Выбор страницы для сохранения
		ЕстьВыбор = Ложь;
		Текст = "";
		Оповещение = Новый ОписаниеОповещения("ОкончаниеВводаТекста", ЭтотОбъект);
		ПоказатьВводСтроки(Оповещение , Текст, "Введите имя графика для сохранения");
		//Если ВвестиСтроку( Текст, "Введите имя графика для сохранения") Тогда
		//	ЕстьВыбор = Истина;
		//КонецЕсли;
		//Если ЕстьВыбор Тогда
		//КонецЕсли;
	Иначе
		stepsX = stepsX_load;
		stepsY = stepsY_load;
		ПерегрузитьИзГалереи();
	КонецЕсли;
	Элементы.View.Видимость = Истина;
	Элементы.new_widgets.Видимость = Ложь;
	ОбновитьОтображение();
КонецПроцедуры

&НаКлиенте
Процедура ОкончаниеВводаТекста( Текст, ДопПараметры) Экспорт
	Адрес = ЗаписатьJSONвХранилище();
	#Если ВебКлиент Тогда
		СохранитьДанныеСервер(Адрес, online_email, Текст, widget_select);
	#Иначе
		СохранитьДанныеКлиент(Адрес, online_email, Текст, widget_select);
	#КонецЕсли
КонецПроцедуры	

&НаСервере
Функция СохранитьДанныеСервер(Адрес, online_email, Текст, widget_select)
	Возврат СохранитьДанные(Адрес, online_email, Текст, widget_select);	
КонецФункции

&НаКлиенте
Функция СохранитьДанныеКлиент(Адрес, online_email, Текст, widget_select)
	Возврат СохранитьДанные(Адрес, online_email, Текст, widget_select);	
КонецФункции	

//Проверить актуальность аккаунта и оплату.
//Возращает  актуальность аккаунту и даты  
// - bad_connect = немогу соединиться
// - bad_user = нет такого e-mail. 
// - "" (пустая строка) = нормально.
// - 2016-01-20 = конец периода.
&НаКлиентеНаСервереБезКонтекста
Функция СохранитьДанные(Адрес, online_email, Текст, widget_select)
	HttpСоединение = Новый HTTPСоединение( "widget.sikuda.ru",,,,,5);
	HttpЗапрос = Новый HTTPЗапрос("/_save.php?email="+online_email+"&title="+Текст+"&offset="+Формат(widget_select,"ЧДЦ=; ЧН=0; ЧГ=0"));
	СтрокаJSON = ПолучитьИзВременногоХранилища(Адрес);
	HttpЗапрос.УстановитьТелоИзСтроки(СтрокаJSON, КодировкаТекста.UTF8);
	мОтвет = HttpСоединение.Записать(HttpЗапрос);
КонецФункции	










