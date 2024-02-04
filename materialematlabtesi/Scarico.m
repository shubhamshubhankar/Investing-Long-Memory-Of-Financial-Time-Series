function [Open,High,Low,Close,AdjClose,Volume] = Scarico(Constituent,n)

for x = 1:length(Constituent)
   x
   azio = strtrim(Constituent{x}); 
   stocks=getMarketDataViaYahoo(azio,datestr(now-n),datestr(now),'1d');
   
   Op = stocks.Open;
   Hi = stocks.High;
   Lo = stocks.Low;
   Cl = stocks.Close;
   AdjCl = stocks.AdjClose;
   Vol = stocks.Volume;
   Time = stocks.Date;
   data=timetable(Time,Op);
   if x==1
      Open=data;
   else
      Open=synchronize(Open,data);
   end

   data=timetable(Time,Hi);
   if x==1
      High=data;
   else
      High=synchronize(High,data);
   end

   data=timetable(Time,Lo);
   if x==1
      Low=data;
   else
      Low=synchronize(Low,data);
   end

   data=timetable(Time,Cl);
   if x==1
      Close=data;
   else
      Close=synchronize(Close,data);
   end

   data=timetable(Time,AdjCl);
   if x==1
      AdjClose=data;
   else
      AdjClose=synchronize(AdjClose,data);
   end

   data=timetable(Time,Vol);
   if x==1
      Volume=data;
   else
      Volume=synchronize(Volume,data);
   end

   pause(1)
end
