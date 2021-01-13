public class PriceInfo_DTO
{
	public List<PriceDetail_DTO> standardPrice { get; set; }
	public List<PriceDetail_DTO> customerPrice { get; set; }
	public List<PriceDetail_DTO> regionPrice { get; set; }
	public List<PriceDetail_DTO> countryPrice { get; set; }
	public List<PriceDetail_DTO> couponPrice { get; set; }
	public List<PriceDetail_DTO> preSalePrice { get; set; }
}
