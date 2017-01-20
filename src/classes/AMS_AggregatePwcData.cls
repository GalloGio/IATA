public with sharing class AMS_AggregatePwcData {

    /**
     * Attributes
     */
    private Integer defCount;
    private Integer dwdCount;
    private Integer defNonPaymentCount;
    private Integer irrsPositiveCount;
    private Integer irrsNegativeCount;
    private Boolean ownShaChange;
    private DateTime ownShaLastDate;

    /**
     * Default constructor
     */
    public AMS_AggregatePwcData() {
        this.defCount = 0;
        this.dwdCount = 0;
        this.defNonPaymentCount = 0;
        this.irrsPositiveCount = 0;
        this.irrsNegativeCount = 0;
        this.ownShaChange = false;
        this.ownShaLastDate = null;
    }

    /**
     * Getter / Setter
     */
    public void setDefCount(Integer defCount) {
        this.defCount = defCount;
    }

    public Integer getDefCount() {
        return defCount;
    }

    public void setDwdCount(Integer dwdCount) {
        this.dwdCount = dwdCount;
    }

    public Integer getDwdCount() {
        return dwdCount;
    }

    public void setDefNonPaymentCount(Integer defNonPaymentCount) {
        this.defNonPaymentCount = defNonPaymentCount;
    }

    public Integer getDefNonPaymentCount() {
        return defNonPaymentCount;
    }

    public void setIrrsPositiveCount(Integer irrsPositiveCount) {
        this.irrsPositiveCount = irrsPositiveCount;
    }

    public Integer getIrrsPositiveCount() {
        return irrsPositiveCount;
    }

    public void setIrrsNegativeCount(Integer irrsNegativeCount) {
        this.irrsNegativeCount = irrsNegativeCount;
    }

    public Integer getIrrsNegativeCount() {
        return irrsNegativeCount;
    }

    public void setOwnShaChange(Boolean ownShaChange) {
        this.ownShaChange = ownShaChange;
    }

    public Boolean getOwnShaChange() {
        return ownShaChange;
    }

    public void setOwnShaLastDate(DateTime ownShaLastDate) {
        this.ownShaLastDate = ownShaLastDate;
    }

    public DateTime getOwnShaLastDate() {
        return ownShaLastDate;
    }

}