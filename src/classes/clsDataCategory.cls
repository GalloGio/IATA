public with sharing class clsDataCategory  implements Comparable {

	public String topCategoryName 	{get;set;}
	public String topCategoryLabel {get;set;}

	public String CategoryName 	{get;set;}
	public String CategoryLabel {get;set;}
	public list<CategoryChildWrapper> lst_childs {get;set;}

	public clsDataCategory(String topCategoryName,
												 String topCategoryLabel,
							 String categoryName,
							 String categoryLabel,
							 list<DataCategory> lst_dc_childs) {

		this.topCategoryName = topCategoryName + '__c';
		this.topCategoryLabel = topCategoryLabel;

		this.CategoryName 	= categoryName + '__c';
		this.CategoryLabel 	= categoryLabel;
		this.lst_childs = new list<CategoryChildWrapper>();

		for(Integer x = 0; x < lst_dc_childs.size(); x++){
			DataCategory dc = lst_dc_childs[x];
			lst_childs.add(new CategoryChildWrapper(dc.getName(),dc.getLabel()));
		}
		lst_childs.sort();
	}

	public map<String, String> name2labelCategoryMap {
		get{
			if(null == name2labelCategoryMap) {
				name2labelCategoryMap = new map<String, String>();
				for(CategoryChildWrapper childCat : this.lst_childs)
					name2labelCategoryMap.put(childCat.CategoryName, childCat.CategoryLabel);
			}
			return  name2labelCategoryMap;
		}
		private set;
	}

	public String getLabelByNameCategory(String catName){
		//system.debug('name2labelCategoryMap >> '  + name2labelCategoryMap + ' ' + name2labelCategoryMap.get(catName));
		return name2labelCategoryMap.get(catName);
	}

	/**
	 * [print description]
	 */
	public void print(){
		System.debug('CategoryName:'+this.CategoryName);
		System.debug('CategoryLabele:'+this.CategoryLabel);
		for(CategoryChildWrapper cc : lst_childs)
			cc.print();
	}

	public Integer compareTo(Object compareTo) {
		clsDataCategory compareToOriginal = (clsDataCategory)compareTo;
		return this.CategoryLabel.compareTo(compareToOriginal.CategoryLabel);
	}

	public class CategoryChildWrapper implements Comparable {

		public String CategoryName 	{get;set;}
		public String CategoryLabel {get;set;}

		public CategoryChildWrapper(String CategoryName,String CategoryLabel) {
			this.CategoryName = CategoryName + '__c';
			this.CategoryLabel = CategoryLabel;
		}

		public Integer compareTo(Object compareTo) {
			CategoryChildWrapper compareToOriginal = (CategoryChildWrapper)compareTo;
			return this.CategoryLabel.compareTo(compareToOriginal.CategoryLabel);
		}

		public void print(){
			System.debug('Child Category');
			System.debug('this.CategoryName:'+this.CategoryName);
			System.debug('this.CategoryLabel:'+this.CategoryLabel);
		}
	}
}
