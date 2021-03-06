package com.btcdd.codeforest.vo;

public class SavePathVo {

	Long no;
	Long subProblemNo;
	Long saveNo;
	String packagePath;
	private String fileName;

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public Long getNo() {
		return no;
	}

	public void setNo(Long no) {
		this.no = no;
	}

	public Long getSubProblemNo() {
		return subProblemNo;
	}

	public void setSubProblemNo(Long subProblemNo) {
		this.subProblemNo = subProblemNo;
	}

	public Long getSaveNo() {
		return saveNo;
	}

	public void setSaveNo(Long saveNo) {
		this.saveNo = saveNo;
	}

	public String getPackagePath() {
		return packagePath;
	}

	public void setPackagePath(String packagePath) {
		this.packagePath = packagePath;
	}

	@Override
	public String toString() {
		return "SavePathVo [no=" + no + ", subProblemNo=" + subProblemNo + ", saveNo=" + saveNo + ", packagePath="
				+ packagePath + "]";
	}

}