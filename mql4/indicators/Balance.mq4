/**
 * Balance-Verlauf des aktuellen Accounts als Linienchart im Indikator-Subfenster
 */
#include <types.mqh>
#define     __TYPE__   T_INDICATOR
int   __INIT_FLAGS__[];
int __DEINIT_FLAGS__[];
#include <stdlib.mqh>


#property indicator_separate_window

#property indicator_buffers 1
#property indicator_color1  Blue


double iBalance[];


/**
 * Initialisierung
 *
 * @param  bool userCall - ob der Aufruf der zugrunde liegenden init()-Funktion durch das Terminal oder durch User-Code erfolgte
 *
 * @return int - Fehlerstatus
 */
int onInit(bool userCall) {
   // ERR_TERMINAL_NOT_YET_READY abfangen
   if (!GetAccountNumber())
      return(SetLastError(stdlib_PeekLastError()));

   SetIndexBuffer(0, iBalance);
   SetIndexLabel (0, "Balance");
   IndicatorShortName("Balance");
   IndicatorDigits(2);

   // nach Parameter�nderung nicht auf den n�chsten Tick warten (nur im "Indicators List" window notwendig)
   if (UninitializeReason() == REASON_PARAMETERS)
      SendTick(false);

   return(catch("onInit()"));
}


/**
 * Main-Funktion
 *
 * @return int - Fehlerstatus
 */
int onTick() {
   // Abschlu� der Buffer-Initialisierung �berpr�fen
   if (ArraySize(iBalance) == 0)                                     // kann bei Terminal-Start auftreten
      return(SetLastError(ERR_TERMINAL_NOT_YET_READY));

   // Alle Werte komplett ...
   if (ValidBars == 0) {
      ArrayInitialize(iBalance, EMPTY_VALUE);      // vor Neuberechnung alte Werte zur�cksetzen
      last_error = iAccountBalanceSeries(AccountNumber(), iBalance);
   }
   else {                                          // ... oder nur die fehlenden Werte berechnen
      for (int bar=ChangedBars-1; bar >= 0; bar--) {
         last_error = iAccountBalance(AccountNumber(), iBalance, bar);
         if (last_error != NO_ERROR)
            break;
      }
   }

   return(catch("onTick()"));
}


