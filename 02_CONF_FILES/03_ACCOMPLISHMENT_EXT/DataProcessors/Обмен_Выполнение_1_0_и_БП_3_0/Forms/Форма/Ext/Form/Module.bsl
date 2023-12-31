﻿&НаКлиенте
Перем Клиент, АдресВоВременномХранилище;

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	//пример для бесплатного https://www.cloudamqp.com/
	
	//Адрес = "flamingo-01.rmq.cloudamqp.com";
	//Порт = 5672;
	//Логин = "dcyuszes";
	//Пароль = "n1ka_691bexu6e27hhqrKUgwBuvJkxx";
	//ВиртуальныйХост = "dcyuszes";
	
	ТочкаОбмена = "data_test";
	ИмяОчереди = "rout_test";
	ТекстСообщения = "Test1";
	
КонецПроцедуры

&НаКлиенте
Процедура ОтправитьДанные(Команда)
	ОбменДаннымиВПБПВызовСервера.ОтправитьДанные(Объект.КаталогОбмена);
КонецПроцедуры

&НаКлиенте
Процедура ОтправитьДанныеЧерезRMQ(Команда)
	
	НастройкиСоединения = ПолучитьНастройкиСоединенияСRMQ();
	ДанныеОтправлены = ОтправитьДанныеЧерезRMQСервер(НастройкиСоединения);

КонецПроцедуры

&НаСервере
Функция ОтправитьДанныеЧерезRMQСервер(НастройкиСоединения)

	КлиентКомпоненты = ПолучитьКомпонентуСервер();  
	Возврат ОтправитьДанныеЧерезRMQКлиентСервер(КлиентКомпоненты,НастройкиСоединения);

КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ОтправитьДанныеЧерезRMQКлиентСервер(КлиентКомпоненты, НастройкиСоединения)
	
	ДанныеДляОтправки = ОбменДаннымиВПБПВызовСервера.ПодготовитьДанные();  
	
	Если НЕ ДанныеДляОтправки.Свойство("МассивСообщений") Тогда
		Возврат Истина;	
	КонецЕсли;

	Для каждого ОтправляемоеСообщение Из ДанныеДляОтправки.МассивСообщений Цикл
		
		Попытка
			КлиентКомпоненты.Connect(
				НастройкиСоединения.Адрес,
				НастройкиСоединения.Порт,
				НастройкиСоединения.Логин,
				НастройкиСоединения.Пароль,
				НастройкиСоединения.Хост);
			
			ТочкаОбмена    		= НастройкиСоединения.Точка;
			КлючМаршрутизации 	= НастройкиСоединения.Ключ;    		

			КлиентКомпоненты.BasicPublish(
				ТочкаОбмена,
				КлючМаршрутизации,
				ОтправляемоеСообщение,
				1,
				Ложь);
		Исключение
			СистемнаяОшибка = ОписаниеОшибки();
			ТекстСообщения = "Ошибка отправки сообщения!%СистемнаяОшибка%";
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СистемнаяОшибка%", СистемнаяОшибка);
			ВызватьИсключение ТекстСообщения;
		КонецПопытки;
	
	КонецЦикла;
		
	Возврат Истина;   
	
КонецФункции

&НаКлиенте
Процедура ПолучитьДанные(Команда)
	ОбменДаннымиВПБПВызовСервера.ПолучитьДанные(Объект.КаталогОбмена);
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьДанныеЧерезRMQ(Команда)

	НастройкиСоединения = ПолучитьНастройкиСоединенияСRMQ();
	ДанныеПолучены = ПолучитьДанныеЧерезRMQСервер(НастройкиСоединения);

КонецПроцедуры

&НаСервере
Функция ПолучитьДанныеЧерезRMQСервер(НастройкиСоединения)

	КлиентКомпоненты = ПолучитьКомпонентуСервер();  
	Возврат ПолучитьДанныеЧерезRMQКлиентСервер(КлиентКомпоненты,НастройкиСоединения);

КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьДанныеЧерезRMQКлиентСервер(КлиентКомпоненты, НастройкиСоединения)
	
	Попытка
		КлиентКомпоненты.Connect(
			НастройкиСоединения.Адрес,
			НастройкиСоединения.Порт,
			НастройкиСоединения.Логин,
			НастройкиСоединения.Пароль,
			НастройкиСоединения.Хост);
		
		ИмяОчереди = НастройкиСоединения.Очередь;
		
		Попытка			
			Потребитель = КлиентКомпоненты.BasicConsume(ИмяОчереди, "", Истина, Ложь, 0);
			
			ПолученноеСообщение = "";
			Если КлиентКомпоненты.BasicConsumeMessage("", ПолученноеСообщение, 5) Тогда
				КлиентКомпоненты.BasicAck();
				ОбменДаннымиВПБПВызовСервера.ПолучитьДанныеИзRMQ(ПолученноеСообщение);
				ТекстСообщения = НСтр("ru='Сообщение успешно прочитано!'");    
			Иначе
				ОбменДаннымиВПБПВызовСервера.ПолучитьДанныеИзRMQ(ПолученноеСообщение);
				ТекстСообщения = НСтр("ru='Очередь пустая!'");
			КонецЕсли;
			//Сообщить(ТекстСообщения);
			
			КлиентКомпоненты.BasicCancel("");
		Исключение
			ВызватьИсключение КлиентКомпоненты.GetLastError();
		КонецПопытки;
	Исключение
		СистемнаяОшибка = ОписаниеОшибки();
		ТекстСообщения = "Ошибка чтения сообщения!%СистемнаяОшибка%";
		ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СистемнаяОшибка%", СистемнаяОшибка);
		УдалитьФайлы("C:\TEMP1C");
		ВызватьИсключение ТекстСообщения;  
		
	КонецПопытки;
	
	УдалитьФайлы("C:\TEMP1C");
	Возврат Истина;	
	
КонецФункции

&НаКлиенте
Процедура КаталогОбменаНачалоВыбора(Элемент, ДанныеВыбора, ВыборДобавлением, СтандартнаяОбработка)

	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	Диалог.Заголовок = "Выберитие каталог с файлами обмена";
	Диалог.МножественныйВыбор = Ложь;

	Если Диалог.Выбрать() Тогда
        Объект.КаталогОбмена = Диалог.Каталог;
    КонецЕсли;

КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьНастройкиСоединенияСRMQ()

	НастройкиСоединения = Новый Структура("Адрес,Порт,Логин,Пароль,Хост,Точка,Ключ,Очередь"); 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	НастройкиОбменаRMQ.Настройка КАК Настройка,
		|	НастройкиОбменаRMQ.Значение КАК Значение
		|ИЗ
		|	РегистрСведений.НастройкиОбменаRMQ КАК НастройкиОбменаRMQ";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	ПолученныеНастройки = Новый Структура;
	
	Пока Выборка.Следующий() Цикл
   		ПолученныеНастройки.Вставить(Выборка.Настройка,Выборка.Значение);	
	КонецЦикла;    
	
	ЗаполнитьЗначенияСвойств(НастройкиСоединения,ПолученныеНастройки);
	
	Возврат НастройкиСоединения;
	
КонецФункции


#Область ПодключениеИнициализацияКомпоненты

&НаКлиенте
Процедура ПодключитьКомпонентуКлиент(КомпонентаПодключена = Неопределено)
	
	АдресВоВременномХранилище = ПолучитьАдресМакетаКомпановкиНаСервере(ЭтаФорма.УникальныйИдентификатор);
	
	УстановитьВнешнююКомпоненту(АдресВоВременномХранилище);
	КомпонентаПодключена = ПодключитьВнешнююКомпоненту(
			АдресВоВременномХранилище,
			"BITERP",
			ТипВнешнейКомпоненты.Native);
	//Сообщить(НСтр("ru = 'Компонента подключена!'"));
КонецПроцедуры

&НаСервере
Процедура ПодключитьКомпонентуСервер(КомпонентаПодключена = Неопределено)
	
	АдресВоВременномХранилище = ПолучитьАдресМакетаКомпановкиНаСервере(ЭтаФорма.УникальныйИдентификатор);
	КомпонентаПодключена = ПодключитьВнешнююКомпоненту(
			АдресВоВременномХранилище,
			"BITERP",
			ТипВнешнейКомпоненты.Native);
	//Сообщить(НСтр("ru = 'Компонента подключена!'"));
КонецПроцедуры

&НаКлиенте
Функция ПолучитьКомпонентуКлиент()
	
	Если Клиент = Неопределено Тогда
		Если Не ИнициализироватьКомпонентуКлиентСервер(Клиент) Тогда
			
			ПодключитьКомпонентуКлиент();
			ИнициализироватьКомпонентуКлиентСервер(Клиент);
			
		КонецЕсли;
	КонецЕсли;
	
	Возврат Клиент;
КонецФункции

&НаСервере
Функция ПолучитьКомпонентуСервер()
	
	КлиентКомпоненты = Неопределено;
	Если Не ИнициализироватьКомпонентуКлиентСервер(КлиентКомпоненты) Тогда
		
		ПодключитьКомпонентуСервер();
		ИнициализироватьКомпонентуКлиентСервер(КлиентКомпоненты);
		
	КонецЕсли;
	
	Возврат КлиентКомпоненты;
КонецФункции

#КонецОбласти

&НаКлиенте
Процедура СозданиеТочкиИОчереди(Команда)
	
	Если ИспользоватьКомпоненту = 0 Тогда
		СозданиеТочкиИОчередиКлиент();
	ИначеЕсли ИспользоватьКомпоненту = 1 Тогда
		СозданиеТочкиИОчередиСервер();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СозданиеТочкиИОчередиКлиент()
	
	КлиентКомпоненты = ПолучитьКомпонентуКлиент();
	СозданиеТочкиИОчередиКлиентСервер(КлиентКомпоненты, Этаформа);
	
КонецПроцедуры

&НаСервере
Процедура СозданиеТочкиИОчередиСервер()
	
	КлиентКомпоненты = ПолучитьКомпонентуСервер();
	СозданиеТочкиИОчередиКлиентСервер(КлиентКомпоненты, ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ОтправитьСообщение(Команда)
	
	Если ИспользоватьКомпоненту = 0 Тогда
		ОтправитьСообщениеКлиент();
	ИначеЕсли ИспользоватьКомпоненту = 1 Тогда
		ОтправитьСообщениеСервер();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтправитьСообщениеКлиент()
	
	КлиентКомпоненты = ПолучитьКомпонентуКлиент();
	ОтправитьСообщениеКлиентСервер(КлиентКомпоненты, ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура ОтправитьСообщениеСервер()
	
	КлиентКомпоненты = ПолучитьКомпонентуСервер();
	ОтправитьСообщениеКлиентСервер(КлиентКомпоненты, ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ПрочитатьСообщение(Команда)
	
	Если ИспользоватьКомпоненту = 0 Тогда
		ПрочитатьСообщениеКлиент();
	ИначеЕсли ИспользоватьКомпоненту = 1 Тогда
		ПрочитатьСообщениеСервер();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПрочитатьСообщениеКлиент()
	
	КлиентКомпоненты = ПолучитьКомпонентуКлиент();
	ПрочитатьСообщениеКлиентСервер(КлиентКомпоненты, ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура ПрочитатьСообщениеСервер()
	
	КлиентКомпоненты = ПолучитьКомпонентуСервер();
	ПрочитатьСообщениеКлиентСервер(КлиентКомпоненты, ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьПодключение(Команда)
	
	Если ИспользоватьКомпоненту = 0 Тогда
		ПроверитьПодключениеКлиент();
	ИначеЕсли ИспользоватьКомпоненту = 1 Тогда
		ПроверитьПодключениеСервер();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьПодключениеКлиент()
	
	КлиентКомпоненты = ПолучитьКомпонентуКлиент();
	ПроверитьПодключениеКлиентСервер(КлиентКомпоненты, ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура ПроверитьПодключениеСервер()
	
	КлиентКомпоненты = ПолучитьКомпонентуСервер();
	ПроверитьПодключениеКлиентСервер(КлиентКомпоненты, ЭтаФорма);
	
КонецПроцедуры

#Область СлужебныеПроцедуры

&НаСервере
Функция ПолучитьАдресМакетаКомпановкиНаСервере(УникальныйИдентификатор)
	
	МакетВнешнейКомпоненты    = РеквизитФормыВЗначение("Объект").ПолучитьМакет("ВнешняяКомпонента");
	АдресВоВременномХранилище = ПоместитьВоВременноеХранилище(МакетВнешнейКомпоненты, УникальныйИдентификатор);
	
	Возврат АдресВоВременномХранилище;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ИнициализироватьКомпонентуКлиентСервер(Компонента)
	
	Попытка
		Компонента  = Новый("AddIn.BITERP.PinkRabbitMQ");
		Возврат Истина;
	Исключение
		Возврат Ложь;
	КонецПопытки;
	
КонецФункции

#КонецОбласти

#Область ПроцедурыРаботаСRabbitMQ

&НаКлиентеНаСервереБезКонтекста
Процедура ПроверитьПодключениеКлиентСервер(КлиентКомпоненты, Форма)
	
	Попытка
		КлиентКомпоненты.Connect(
				Форма.Адрес,
				Форма.Порт,
				Форма.Логин,
				Форма.Пароль,
				Форма.ВиртуальныйХост);
			Исключение
		СистемнаяОшибка = ОписаниеОшибки();
		ТекстСообщения = "Ошибка подключения!%СистемнаяОшибка%";
		ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СистемнаяОшибка%", СистемнаяОшибка);
		ВызватьИсключение ТекстСообщения;
	КонецПопытки;
	
	Сообщить(НСтр("ru = 'Подключение успешно выполнено!'"));
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура СозданиеТочкиИОчередиКлиентСервер(КлиентКомпоненты, Форма)
	
	Попытка
		КлиентКомпоненты.Connect(
			Форма.Адрес,
			Форма.Порт,
			Форма.Логин,
			Форма.Пароль,
			Форма.ВиртуальныйХост);
			
		ТочкаОбмена = Форма.ТочкаОбмена;
		ИмяОчереди  = Форма.ИмяОчереди;
		
		КлиентКомпоненты.DeclareExchange(ТочкаОбмена, "topic", Ложь, Истина, Ложь);
		КлиентКомпоненты.DeclareQueue(ИмяОчереди, Ложь, Ложь, Ложь, Ложь);
		КлиентКомпоненты.BindQueue(ИмяОчереди, ТочкаОбмена, "#" + ИмяОчереди + "#");
	Исключение
		СистемнаяОшибка = ОписаниеОшибки();
		ТекстСообщения = "Ошибка создания точек и очередей!%СистемнаяОшибка%";
		ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СистемнаяОшибка%", СистемнаяОшибка);
		ВызватьИсключение ТекстСообщения;
	КонецПопытки;
	
	Сообщить("Точки и очереди успешно созданы!");
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ОтправитьСообщениеКлиентСервер(КлиентКомпоненты, Форма)
	
	Попытка
		КлиентКомпоненты.Connect(
			Форма.Адрес,
			Форма.Порт,
			Форма.Логин,
			Форма.Пароль,
			Форма.ВиртуальныйХост);
		
		ТочкаОбмена    = Форма.ТочкаОбмена;
		ИмяОчереди     = Форма.ИмяОчереди;
		ТекстСообщения = Форма.ТекстСообщения;
		КлючМаршрутизации = Форма.КлючМаршрутизации;
		
		КлиентКомпоненты.BasicPublish(
			ТочкаОбмена,
			КлючМаршрутизации,
			ТекстСообщения,
			1,
			Ложь);
	Исключение
		СистемнаяОшибка = ОписаниеОшибки();
		ТекстСообщения = "Ошибка отправки сообщения!%СистемнаяОшибка%";
		ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СистемнаяОшибка%", СистемнаяОшибка);
		ВызватьИсключение ТекстСообщения;
	КонецПопытки;
	
	Сообщить("Сообщение успешно отправлено!");
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ПрочитатьСообщениеКлиентСервер(КлиентКомпоненты, Форма)
	
	Попытка
		КлиентКомпоненты.Connect(
			Форма.Адрес,
			Форма.Порт,
			Форма.Логин,
			Форма.Пароль,
			Форма.ВиртуальныйХост);
		
		ИмяОчереди = Форма.ИмяОчереди;
		
		Попытка
			//КлиентКомпоненты.DeclareQueue(ИмяОчереди, Ложь, Ложь, Ложь, Ложь);
			
			Потребитель = КлиентКомпоненты.BasicConsume(ИмяОчереди, "", Истина, Ложь, 0);
			
			ОтветноеСообщение = "";
			Если КлиентКомпоненты.BasicConsumeMessage("", ОтветноеСообщение, 5) Тогда
				КлиентКомпоненты.BasicAck();
				Форма.ОтветноеСообщение = ОтветноеСообщение;
				ТекстСообщения = НСтр("ru='Сообщение успешно прочитано!'");
			Иначе
				Форма.ОтветноеСообщение = ОтветноеСообщение;
				ТекстСообщения = НСтр("ru='Очередь пустая!'");
			КонецЕсли;
			Сообщить(ТекстСообщения);
			
			КлиентКомпоненты.BasicCancel("");
		Исключение
			ВызватьИсключение КлиентКомпоненты.GetLastError();
		КонецПопытки;
	Исключение
		СистемнаяОшибка = ОписаниеОшибки();
		ТекстСообщения = "Ошибка чтения сообщения!%СистемнаяОшибка%";
		ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СистемнаяОшибка%", СистемнаяОшибка);
		ВызватьИсключение ТекстСообщения;
	КонецПопытки;
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкиRMQ(Команда)
	ОткрытьФорму("РегистрСведений.НастройкиОбменаRMQ.ФормаСписка",,ЭтаФорма,,,,,РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
КонецПроцедуры

#КонецОбласти
