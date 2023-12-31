﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	Если Параметры.Свойство("МассивНоменклатуры") Тогда 
		Для каждого СтрокаНоменклатуры Из Параметры.МассивНоменклатуры Цикл
			НоваяСтрока = Объект.Товары.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока,СтрокаНоменклатуры,"Спецификация,НомерПоСпецификации,НоменклатураКлиента,КоличествоПоСпецификации");
			
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыКоличествоПриИзменении(Элемент)
	ПересчитатьДанныеСтроки(Элемент);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаПриИзменении(Элемент)
	ПересчитатьДанныеСтроки(Элемент);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыСуммаПриИзменении(Элемент)
	ПересчитатьДанныеСтроки(Элемент);
КонецПроцедуры

&НаКлиенте
Процедура ПересчитатьДанныеСтроки(Элемент)

	ТекДанные = Элементы.Товары.ТекущиеДанные;
	
	Если ТекДанные = Неопределено Тогда 
		Возврат;	
	КонецЕсли;
	
	Если Элемент.Имя = "ТоварыКоличество" ИЛИ Элемент.Имя = "ТоварыЦена" Тогда
		ТекДанные.Сумма = ТекДанные.Количество * ТекДанные.Цена;		
	ИначеЕсли Элемент.Имя = "ТоварыСумма" Тогда
    	ТекДанные.Цена = ?(ТекДанные.Количество = 0,0,ТекДанные.Сумма / ТекДанные.Количество); 
	КонецЕсли;	
		
КонецПроцедуры
