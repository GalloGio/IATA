public with sharing class CurrencySingleton {

	private static CurrencySingleton instance = null;
	private map<string,CurrencyType> mapCurrencies;

	private CurrencySingleton() {
		this.mapCurrencies = new map<string,CurrencyType>();
		for(CurrencyType currtype : [Select Id, IsoCode, IsCorporate, IsActive, DecimalPlaces, ConversionRate From CurrencyType]){
			this.mapCurrencies.put( currtype.IsoCode, currType);
		}
	}

	public static CurrencySingleton getInstance(){
		if(instance == null) {
			instance = new CurrencySingleton();
		}
		return instance;
	}

	public Decimal getConversionRate(String oldCurrency, String newCurrency) {
		try {
			Decimal oldConversionRate = this.mapCurrencies.get(oldCurrency).ConversionRate;
			Decimal newConversionRate = this.mapCurrencies.get(newCurrency).ConversionRate;
			return (newConversionRate / oldConversionRate);
		} catch ( Exception e ) {
			return null;
		}
	}

	public Decimal convertCurrency( Decimal amount, String oldCurrency, String newCurrency ) {
		if ( oldCurrency == newCurrency ) return amount;
		Decimal rate = getConversionRate(oldCurrency, newCurrency);
		if ( rate == null ) return null;
		return amount * rate;
	}

}
