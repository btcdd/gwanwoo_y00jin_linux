package com.btcdd.codeforest.controller.api;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.btcdd.codeforest.dto.JsonResult;
import com.btcdd.codeforest.service.MypageService;
import com.btcdd.codeforest.vo.ProblemVo;
import com.btcdd.codeforest.vo.SubProblemVo;
import com.btcdd.codeforest.vo.SubmitVo;
import com.btcdd.codeforest.vo.UserVo;
import com.btcdd.security.Auth;

@RestController("MypageController")
@RequestMapping("/api/mypage")
public class MypageController {

	@Autowired
	private MypageService mypageService;
	
	@Auth
	@PostMapping(value = "/account/nickname")
	public JsonResult changeNickname(@ModelAttribute UserVo vo, HttpSession session) {
		mypageService.changeNickname(vo);
		UserVo authUser = (UserVo) session.getAttribute("authUser");
		authUser.setNickname(vo.getNickname());
		session.setAttribute("authUser", authUser);
		return JsonResult.success(authUser.getNickname());
	}

	@Auth
	@PostMapping(value = "/account/password")
	public JsonResult changePassword(@ModelAttribute UserVo vo) {
		int result = mypageService.changePassword(vo);

		return JsonResult.success(result);
	}

	@Auth
	@PostMapping(value = "/account/delete")
	public JsonResult deleteUser(@ModelAttribute UserVo vo, HttpSession session) {
		int result = mypageService.deleteUser(vo);
		session.setAttribute("authUser", null);

		return JsonResult.success(result);
	}

	@Auth
	@DeleteMapping(value = "/problem/delete/{no}")
	public JsonResult deleteProblem(@PathVariable("no") Long no) {
		int result = mypageService.deleteProblem(no);
		return JsonResult.success(result);
	}

	@Auth
	@DeleteMapping(value = "/sub-problem/delete/{no}")
	public JsonResult deleteSubProblem(@PathVariable("no") Long no) {
		int result = mypageService.deleteSubProblem(no);
		
		return JsonResult.success(result);
	}

	// 문제 푼 사람 리스트
	@Auth
	@PostMapping(value = "/problem/list/{no}")
	public JsonResult listProblem(@PathVariable("no") Long no) {
		List<SubmitVo> result = mypageService.problemSolveList(no);

		return JsonResult.success(result);
	}

	@Auth
	@PostMapping(value = "/sub-problem/{no}")
	public JsonResult subProblem(@PathVariable("no") Long no) {
		List<SubProblemVo> result = mypageService.findSubProblem(no);

		return JsonResult.success(result);
	}

	@Auth
	@PostMapping(value = "/account/privacy")
	public JsonResult privacyChange(String privacy, HttpSession session) {
		UserVo authUser = (UserVo) session.getAttribute("authUser");

		mypageService.privacyChange(authUser.getNo(), privacy);

		return JsonResult.success(null);
	}

	@Auth
	@PostMapping(value = "/problem")
	public JsonResult findProblem(String page, String keyword, Boolean mailChecked, HttpSession session) {
		UserVo authUser = (UserVo) session.getAttribute("authUser");
		
		int currentPage = Integer.parseInt(page);
		Map<String, Object> map = mypageService.getContentsList(currentPage, authUser.getNo(), keyword, mailChecked);
	
		return JsonResult.success(map);
	}
	
	@Auth
	@PostMapping(value="/codemirror")// Code Tree에서 리스트 창 띄울때
	public JsonResult codemirror(Long problemNo, Long userNo) {
		Long saveNo = mypageService.findSaveNoByProblemNoAndUserNo(problemNo, userNo);
		Map<String, Object> map = new HashMap<>();
		map.put("saveNo",saveNo);
		return JsonResult.success(map);
	}

	@Auth
	@PostMapping(value = "/problem/sendMail")
	public JsonResult sendMail(String[] emailArray, Long problemNo) {
		ProblemVo problemVo = mypageService.getProblemPasswordAndTitle(problemNo);
		mypageService.sendMail(emailArray, problemVo);
		
		return JsonResult.success(null);
	}
}