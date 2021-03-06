package com.rest;

import java.lang.StringBuilder;
import java.io.PrintWriter;
import java.util.Calendar;
import java.io.File;
%%

%public
%class Query //change this to change generated name
%unicode
%type String
%standalone
%ignorecase //ignores case from user search
%{
  boolean today = true; //default if user doesn't specify day
  StringBuilder sb = new StringBuilder();
  StringBuilder itemBuild = new StringBuilder();
  String fin = "";
  String getString() {
	return fin;
  }
  Calendar cal = Calendar.getInstance();
  String[] days_of_week = {"sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"};
%}

DiningCourt = wiley|earhart|meredith|ford|hillenbrand|windsor|"the gathering place"
DayWeek = monday|tuesday|wednesday|thursday|friday|saturday|sunday|tomorrow|today  
MealTime = lunch|dinner|breakfast|late\ lunch
Modifier = more|less|greater|above|under|below|over|larger|fewer|exceeding|lower|equal|equals|around|>|<|"="|about
Trash = a|meal|of|with|calories|than|be|have|for|what|whats|there|to|eat|where|at|is|what's|can|on|will|get|i|any|yash|does|we|you|us
TrashWords = (have|for|at|there|{MealTime}|{DayWeek}|{DiningCourt})
SigWord = !({TrashWords}|\ )
%%

{Trash}  {
}
/* {TrashWords}\ {SigWord}\ {TrashWords} {
	String match = yytext();
	sb.append("ITEM_NAME=");
	String item = match.substring(match.indexOf(" ")+1,match.lastIndexOf(" "));
	sb.append(item + ";");
	yypushback(match.substring(match.lastIndexOf(" ")).length());
} */

{DiningCourt} { 
String match = yytext();
if(match.equals("meredith"))
	match = "the gathering place";
sb.append("DINING_COURT=");
sb.append(match + ";");
}


[1-9][0-9][0-9]*  {
String calories = yytext();
sb.append("CALORIES=");
sb.append(calories + ";");
}

{Modifier} {
	String s = yytext();
	sb.append("MODIFIER=");
	if (s.equals("more") || s.equals("greater") || s.equals("above")
			|| s.equals("larger") || s.equals("over") || s.equals("exceeding")) {
		sb.append(">;");
	} else if (s.equals("=") || s.equals("around") || s.equals("equal") || s.equals("equals") || s.equals("about")) {
		sb.append("=;");
	} else {
		sb.append("<;");
	}
}

{DayWeek} {
today = false;
String in = yytext();
sb.append("MEAL_DAY=");
int current = cal.get(cal.DAY_OF_WEEK);
int desired = 0;
for(int i = 0; i < 7; i++) {
	if(in.equals(days_of_week[i])) {
		desired = i + 1;
		break;
	}
}
int days_to_add = (desired - current);
if(days_to_add < 0) {
	days_to_add += 7;
}
if(in.equals("tomorrow")) days_to_add = 1;
if(in.equals("today")) days_to_add = 0;
cal.add(Calendar.DATE, days_to_add);
String month = String.format("%02d", cal.get(Calendar.MONTH)+1);
String day = String.format("%02d", cal.get(Calendar.DATE));
String year = Integer.toString(cal.get(Calendar.YEAR));
String date = String.format("%s-%s-%s", month, day, year);
sb.append(date + ";");
}

{MealTime} {
sb.append("MEAL_TIME=");
sb.append(yytext() + ";" );
}

[a-z'A-Z]+ {
	itemBuild.append(yytext() + " ");
}	

<<EOF>>   {           //executed after search is lexed;
if(today) {
	String date = String.format("%02d-%02d-%d",cal.get(Calendar.MONTH)+1, cal.get(Calendar.DATE), cal.get(Calendar.YEAR));
	sb.append("MEAL_DAY=" + date + ";");
}
String item = itemBuild.toString();
if(!item.equals("")) sb.append("ITEM_NAME="+item.substring(0,item.length()-1)+";");
String fin = sb.toString().substring(0,sb.length()-1);
File f = new File("/home/cs307/Intelligent-Search/files/tokens.txt");
//File f = new File("in1.txt");
PrintWriter writer = new PrintWriter(f);
writer.println(fin);
System.out.println(fin);
writer.close();
return fin;
}


[^]       {     //excess input ignored (for now)
	
}
