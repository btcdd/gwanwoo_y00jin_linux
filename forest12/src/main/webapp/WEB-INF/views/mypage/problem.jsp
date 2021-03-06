<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>

<head>
<meta charset="UTF-8">
<title>Code Forest</title>
<link rel="stylesheet" href="${pageContext.servletContext.contextPath }/assets/css/include/mypage-header.css">
<link rel="stylesheet" href="${pageContext.servletContext.contextPath }/assets/css/include/footer.css">
<link rel="stylesheet" href="${pageContext.servletContext.contextPath }/assets/css/mypage/problem.css">
<link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
<script type="text/javascript" src="${pageContext.servletContext.contextPath }/assets/js/jquery/jquery-3.4.1.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
<script type="text/javascript" src="${pageContext.servletContext.contextPath }/assets/js/jquery/table2excel.js"></script>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.13.0/css/all.min.css" rel="stylesheet">
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.14.3/xlsx.full.min.js"></script>
<script>

var index = 2;
var rightPandan = false;

var slide = function Slide(str) {
	$("#" + str).slideDown(500);
	$("#" + str).delay(2000).slideUp(500);
}

var checkEmail = function CheckEmail(str) {
    var reg_email = /^([0-9a-zA-Z_\.-]+)@([0-9a-zA-Z_-]+)(\.[0-9a-zA-Z_-]+){1,2}$/;
    if(!reg_email.test(str)) {
    	return false;
    } else {
        return true;
    }
}

var loadingWithMask = function LoadingWithMask(){
	
 	var widthWindow = window.innerWidth;
	var heightWindow = window.innerHeight;

	var mask = "<div id='mask' style='width: 100%;height: 100%;top: 0px;left: 0px;position: fixed;display: none; opacity: 0.9; background-color: #fff;  text-align: center;'></div>";
	var loadingImg = '';
		
	loadingImg += "<div id='loadingImg'>";
	loadingImg += "<span style='position: absolute; top: 40%; left: 44.5%;'></span>";
	loadingImg += "</div>";
		
	$('body').append(mask).append(loadingImg);
	$('#mask').css({
		'width':widthWindow,
		'height':heightWindow,
		'opacity':'0.3'
	});
	$('#mask').show();
	$('#loadingImg').show();
}

var closeLoadingWithMask = function CloseLoadingWithMask() {
	$('#mask, #loadingImg').hide();
	$('#mask, #loadingImg').empty();
}

function onKeyDown() {
	if(event.keyCode == 13) {
		var kwd = $('#kwd').val();
		originList('1', kwd);
		$('span b').trigger('click');
	}
}

var page = '1';
var endPageTrueNum;
var mailChecked = false;
var sendMailProblemNo;

var originList = function(page2, keyword) {
	
   $.ajax({
      url: '${pageContext.request.contextPath }/api/mypage/problem',
      async: false,
      type: 'post',
      dataType: 'json',
      traditional: true,
      data: {
         'page': page2,
         'keyword': keyword,
         'mailChecked': mailChecked
      },
      success: function(response){
         if(response.result != "success"){
            console.error(response.message);
            return;
         }
         map = response.data;
         
         if(map.count / 10 % 1 == 0) {
        	 endPageTrueNum = map.count / 10;
         } else {
	         endPageTrueNum = parseInt(map.count / 10 + 1);
         }
         
         fetchList();
      },
      error: function(xhr, status, e){
         console.error(status + ":" + e);
      }
   });
}

function leadingZeros(n, digits) {
	  var zero = '';
	  n = n.toString();

	  if (n.length < digits) {
	    for (i = 0; i < digits - n.length; i++)
	      zero += '0';
	  }
	  return zero + n;
}

function getTimeStamp() {
	  var d = new Date();
	  var s =
	    leadingZeros(d.getFullYear(), 4) + '-' +
	    leadingZeros(d.getMonth() + 1, 2) + '-' +
	    leadingZeros(d.getDate(), 2) + ' ' +

	    leadingZeros(d.getHours(), 2) + ':' +
	    leadingZeros(d.getMinutes(), 2) + ':' +
	    leadingZeros(d.getSeconds(), 2);

	  return s;
}

var fetchList = function() {
    $("#problem-tbody").remove();
   $("#pager").remove();
   
   var str = "";
   var codingTestStr = "";
   var fileDownloadStr = "";
   str += '<tbody id="problem-tbody">';
   for(var i = 0; i < map.list.length; i++){
	   
	   if(map.list[i].startTime <= getTimeStamp() && map.list[i].endTime >= getTimeStamp()) {
		   titleStr = map.list[i].title;
		   codingTestStr = '<td><button class="blinking" id="modify-btn" style="padding: 2px 9px; background-color: #fc9303; border: 1px solid #fc9303; outline: none; cursor: default" >진행중</button></a></td>';
		   fileDownloadStr = '<td>';
		   if(mailChecked == false) {
			   fileDownloadStr += '<i class="list-none fas fa-file-download"></i></td>';
		   } else {
			   fileDownloadStr += '<i class="fas fa-envelope-square" id="send-mail-icon"></i></td>';
		   }
	   } else if(map.list[i].startTime > getTimeStamp()) {
		   titleStr = map.list[i].title + '<span class="blinking" id="expected" style="color: #fff; background-color: #3e91b5; border: 1px solid #3e91b5; border-radius: 0.5rem; padding: 0 1em; margin-left: 1em; font-size: 0.8em; margin-top: 2px;outline: none; cursor: default" >예정</span>';
		   codingTestStr = '<td><a href="${pageContext.servletContext.contextPath }/training/modify/' + map.list[i].no + '"><button id="modify-btn">수정</button></a></td>';
		   fileDownloadStr = '<td>';
		   if(mailChecked == false) {
			   fileDownloadStr += '<i class="list-none fas fa-file-download"></i></td>';
		   } else {
			   fileDownloadStr += '<i class="fas fa-envelope-square" id="send-mail-icon"></i></td>';
		   }
	   } else if(map.list[i].privacy == null) {
		   titleStr = map.list[i].title;
		   codingTestStr = '<td><a href="${pageContext.servletContext.contextPath }/training/modify/' + map.list[i].no + '"><button id="modify-btn">수정</button></a></td>';
		   fileDownloadStr = '<td>';
		   if(mailChecked == false) {
			   fileDownloadStr += '<i class="list-none fas fa-file-download"></i></td>';
		   } else {
			   fileDownloadStr += '<i class="fas fa-envelope-square" id="send-mail-icon"></i></td>';
		   }
	   } else if(map.list[i].privacy != null && map.list[i].endTime <= getTimeStamp()){ 
		   titleStr = map.list[i].title;
		   codingTestStr = '<td><a href="${pageContext.servletContext.contextPath }/training/view/' + map.list[i].no + '"><button id="end-btn">마감</button></a></td>';
		   fileDownloadStr = '<td>';
		   if(mailChecked == false) {
			   fileDownloadStr += '<i data-no="' + map.list[i].no + '" data-title="' + map.list[i].title + '" type="button" alt="list" class="list fas fa-file-download" id="mail-change-icon"></i></td>';
		   } else {
			   fileDownloadStr += '<i class="fas fa-envelope-square" id="send-mail-icon"></i></td>';
		   }
	   } else {
		   titleStr = map.list[i].title;
		   codingTestStr = '<td><a href="${pageContext.servletContext.contextPath }/training/modify/' + map.list[i].no + '"><button id="modify-btn">수정</button></a></td>';
		   fileDownloadStr = '<td>';
		   if(mailChecked == false) {
			   fileDownloadStr += '<i data-no="' + map.list[i].no + '" data-title="' + map.list[i].title + '" type="button" alt="list" class="list fas fa-file-download" id="mail-change-icon"></i></td>';
		   } else {
			   fileDownloadStr += '<i class="fas fa-envelope-square" id="send-mail-icon"></i></td>';
		   }
	   }
	   
       str += '<tr class="list-contents" id="list-contents" data-no="' + map.list[i].no + '">' + 
                '<td><a data-no="' + map.list[i].no + '">' + map.list[i].no + '</a></td>' + 
                  '<td class="problem-title" data-no="' + map.list[i].no + '" style="text-align: left">' + titleStr + '</td>' + 
                  '<td>' + map.list[i].hit + '</td>' + 
                  '<td>' + map.list[i].recommend + '</td>' + 
                  codingTestStr + 
                  fileDownloadStr;
                  if(map.list[i].startTime <= getTimeStamp() && map.list[i].endTime >= getTimeStamp()) {
                	  str += '<td></td>';
                  } else {
                  	str += '<td><i data-no="' + map.list[i].no + '" alt="delete" class="delete fas fa-minus-circle"></i></td>';
                  }
                str += '</tr>' + 
             '<tr class="sub-problem-contents' + map.list[i].no + '">' + 
                '<td></td>' + 
                 '<td colspan="5">' + 
                     '<table id="sub-problem-table" class="' + map.list[i].no + '" style="display: none;">' + 
                        '<tbody class="sub-problem-tbody"></tbody>' + 
                     '</table>' + 
                 '</td>' + 
                '</tr>';
   }
   str += '</tbody>';
   $(".quiz-table").append(str);
   
   var str2 = '<div class="pager" id="pager">';
   
   if(page != '1'){
      str2 += '<span class="prev"><i class="fas fa-angle-left"></i></span>';
   }   
   for(var i = map.startPageNum; i < map.endPageNum; i++){
      str2 += '<span class="page" id="' + i + '">';
      if(map.select != i ) {
         str2 += i;
      }
      if(map.select == i){
         str2 += '<b>'+i+'</b>';
      }
      str2 += '</span>';
   }
   if(map.endPageNum != page){
      str2 += '<span class="next"><i class="fas fa-angle-right"></i></span>';
   }    
   str2 += "</div>";
      
   $(".quiz-table").after(str2);
   
   nextRemove();
}

var nextRemove = function() {
	var endPage = endPageTrueNum;
	
	if(page == endPage) {
		$('.next').remove();
	}
}

var sendMail = function(emailArray) {

	loadingWithMask();
	
	slide("send-mail");
	
	setTimeout(function() {
		$.ajax({
		      url: '${pageContext.request.contextPath }/api/mypage/problem/sendMail',
		      async: false,
		      type: 'post',
		      dataType: 'json',
		      traditional: true,
		      data: {
		         'emailArray': emailArray,
		         'problemNo': sendMailProblemNo
		      },
		      success: function(response){
	         	 closeLoadingWithMask();
	 	         $("#mail-dialog").dialog("close");
	 	         rightPandan = false;
		      },
		      error: function(xhr, status, e) {
		         console.error(status + ":" + e);
		      }
		   });
	}, 1000)
}
	

$(function() {
	
	originList('1', '');
	
	$(document).on("click", ".page", function() {
	      page = $(this).attr('id');
	      
	      var kwd = $('#kwd').val();
		  originList(page, kwd);
	      nextRemove();
	   });
	   
	   $(document).on("click", ".prev", function() {
	      page = $('span b').parent().attr('id');
	      var prevNo = parseInt(page) - 1;
	      page = String(prevNo);
	      
	      var kwd = $('#kwd').val();
		  originList(page, kwd);
	      nextRemove();
	   });
	   
	   $(document).on("click", ".next", function() {
	      page = $('span b').parent().attr('id');
	      var prevNo = parseInt(page) + 1;
	      page = String(prevNo);
	      
	      var kwd = $('#kwd').val();
		  originList(page, kwd);
	      nextRemove();
	   });
	
	var dialogDelete = $("#dialog-delete").dialog({
		autoOpen: false,
		resizable: false,
		height: "auto",
		width: 400,
		modal: true,
		buttons: {
			"삭제": function() {
				var no = $("#hidden-no").val();
				$.ajax({
					url: '${pageContext.servletContext.contextPath }/api/mypage/problem/delete/' + no,
					async: true,
					type: 'delete',
					dataType: 'json',
					data: '',
					success: function(response) {
						dialogDelete.dialog('close');
						// 삭제 추가해야하는 곳
						$(".list-contents[data-no=" + no + "]").remove();
						$(".sub-problem-contents" + no).remove();
						
						page = $('span b').parent().attr('id');
						var kwd = $('#kwd').val();
						
						originList(page, kwd);
					},
					error: function(xhr, status, e) {
						console.error(status + ":" + e);
					}
				});
			},
			"취소": function() {
				$(this).dialog('close');
			}
		},
		close: function() {
			$("#hidden-no").val('');
			$("#dialog-delete-form p.validateTips.error").hide();
		}
	});
	
	$(document).on('click', '.delete', function(event) {
		event.preventDefault();
		
		var no = $(this).data('no');
		$('#hidden-no').val(no);
		dialogDelete.dialog('open');
	});
	
	// ------------------------------------- 문제 푼 사람 리스트 출력 --------------------------------------
	var dialogList = $(".problem-list").dialog({
		autoOpen: false,
		resizable: false,
		height: 600,
		width: 1040,
		modal: true,
		buttons: {
			"다운로드": function() {		
				var title = $("#hidden-title").val();
				$(".problem-list-table").table2excel({
					exclude: ".discard",
					filename: title.concat(".xls")
				})
			},
			"취소": function() {
				$(this).dialog('close');
			}
		},
		close: function() {
			$(".problem-list-table tr th").removeClass();
			$(".problem-list-table tr th").show();
			$(".box-component").each(function(){
			       $(this).prop('checked',true);
			});
			$(".problem-list-table > #tbody > tr").remove();
			$("#hidden-no").val('');
		}
	});
	
	var problemNo = null;
	$(document).on('click', '.list', function(event) {
		event.preventDefault();
		
		var no = $(this).data('no');	
		problemNo = no;
		var title = $(this).data('title');
		$('#hidden-title').val(title);
		
		$.ajax({
			url: '${pageContext.servletContext.contextPath }/api/mypage/problem/list/' + no,
			async: true,
			type: 'post',
			dataType: 'json',
			data: '',
			success: function(response) {
				var table = "";
				for(var i in response.data) {
					if(response.data[i].solveTime == null) {
						response.data[i].solveTime = "";
					}
					if(response.data[i].name == null) {
						response.data[i].name = "";
					}
					table += "<tbody id='tbody'>" +
							"<tr><td class='discard' id='go-codetree'>" + "<i class='fas fa-laptop-code' data-no='" + response.data[i].userNo + "'></i>" + "</td>" +
							"<td id='name'>" + response.data[i].name + "</td>" +
							"<td id='email'>" + response.data[i].email + "</td>" + 
							"<td id='nickname'>" + response.data[i].nickname + "</td>" +
							"<td id='try-count'>" + response.data[i].tryCount + "</td>" + 
							"<td id='lang'>" + response.data[i].lang + "</td>" +
							"<td id='solve-time'>" + response.data[i].solveTime + "</td></tr></tbody>";
				}
				$(".problem-list-table").append(table);
				dialogList.dialog('open');
			},
			error: function(xhr, status, e) {
				console.error(status + ":" + e);
			}
		});
	});
	
	
	$(document).ready(function(){
	    $(".check-box input").on('click', function(){
	    	var value = $(this).val();
	        if($(this).prop("checked")){
	        	$(".problem-list-table > #tbody > tr > td#".concat(value)).show();
	        	$(".problem-list-table > #tbody > tr > td#".concat(value)).removeClass();
				$(".problem-list-table tr th#".concat(value)).show();
				$(".problem-list-table tr th#".concat(value)).removeClass();
	        }else{
	        	$(".problem-list-table > #tbody > tr > td#".concat(value)).hide();
	        	$(".problem-list-table > #tbody > tr > td#".concat(value)).addClass('discard');
				$(".problem-list-table tr th#".concat(value)).hide();
				$(".problem-list-table tr th#".concat(value)).addClass('discard');
	        }
	    });
	});
	
	// ------------------------------------------- 서브 문제 출력 -------------------------------------------------------
	$(document).on('click', ".problem-title", function() { 
    	var no = $(this).data('no');
    	
    	if($("." + no).css('display') == 'none') {
    		$("." + no + " > .sub-problem-tbody > tr").remove();
    	}
    	
        $.ajax({
			url: '${pageContext.servletContext.contextPath }/api/mypage/sub-problem/' + no,
			async: true,
			type: 'post',
			dataType: 'json',
			data: '',
			success: function(response) {
				if(response.data.length == 0) {
					return;
				}
				var tr = "";
				deleteStr = "";
				
				var expected = $(".problem-title[data-no='" + no + "']").children().attr('id');
				for(var i in response.data) {
					if(expected == "expected") {
						deleteStr = '<td><i data-no="' + response.data[i].no + '" type="button" alt="delete" class="sp-delete fas fa-minus-circle"></i></td>';
					} else {
						deleteStr = '<td></td>';
					}
					tr += '<tr id="sub-problem' + response.data[i].no + '"><td class="sub-problem-padding1"># ' + response.data[i].no +'</td>' + 
						'<td class="sub-problem-padding2">' + response.data[i].title + '</td>' + deleteStr + '</tr>'
				}			
				$("." + no + " .sub-problem-tbody").append(tr);
				$("." + no).toggle();
			},
			error: function(xhr, status, e) {
				console.error(status + ":" + e);
			}
		});    
	});
	
	// ----------------------------------------------- 서브 문제 삭제 ----------------------------------------
	var dialogSpDelete = $("#dialog-delete-sp").dialog({
		autoOpen: false,
		resizable: false,
		height: "auto",
		width: 400,
		modal: true,
		buttons: {
			"삭제": function() {
				var no = $("#hidden-sp-no").val();
				var tableClass = $("#hidden-table-class").val();
				$.ajax({
					url: '${pageContext.servletContext.contextPath }/api/mypage/sub-problem/delete/' + no,
					async: true,
					type: 'delete',
					dataType: 'json',
					data: '',
					success: function(response) {		
						dialogSpDelete.dialog('close');						
						$('#sub-problem'+no).remove();
					},
					error: function(xhr, status, e) {
						console.error(status + ":" + e);
					}
				});
			},
			"취소": function() {
				$(this).dialog('close');
			}
		},
		close: function() {			
			$("#hidden-sp-no").val('');
			$("#hidden-table-class").val('');
		}
	});
	
	$(document).on('click', '.sp-delete', function(event) {
		event.preventDefault();
		
		var spNo = $(this).data('no');
		var tableClass = $("#sub-problem-table").attr('class');
		$('#hidden-sp-no').val(spNo);
		$('#hidden-table-class').val(tableClass);
		dialogSpDelete.dialog('open');
	});
	
	$('#search').on('click', function() {
		var kwd = $('#kwd').val();
		originList('1', kwd);
		$('span b').trigger('click');
	});
	
	//------------------------ 코드보러가기 ------------------------------
	$(document).on("click",".fa-laptop-code",function(){			
		var userNo = $(this).data('no');
		$.ajax({
	          url:'${pageContext.request.contextPath }/api/mypage/codemirror/',
	          async:false,
	          type:'post',
	          dataType:'json',
	          data : {
	        	  'problemNo':problemNo,
	        	  'userNo' : userNo
	        	  },
	          success:function(response){
 				 var codetreeURL = '${pageContext.request.contextPath }/mypage/codemirror/' + response.data.saveNo
			     window.open(codetreeURL,'_blank');  
	          },
	          error: function(xhr, status, e) {
	             console.error(status + ":" + e);
	          }
	       }); 
		
	});
	
	$("#mail-dialog").dialog({
        autoOpen: false,
        resizable: false,
        height: "auto",
        width: 309,
        modal: true,
        buttons: {
            "전송": function() {
            	if(rightPandan == false) {
            		alert('빈 값은 전송 불가합니다');
            		return false;
            	}
            	
            	var textArray = document.getElementsByClassName('input-mail');
				var mailArray = [];
            	
            	for(var i = 0; i < textArray.length; i++) {
            		mailArray.push(textArray[i].value);
            	}
            	sendMail(mailArray);
            },
            "취소": function() {
                $(this).dialog("close");
            }
        }
    });
	
	$(document).on('click', '#send-mail-icon', function(event) {
		event.preventDefault();
		
		sendMailProblemNo = $(this).parent().parent().children().eq(0).text();
		
		$('#mail-dialog').dialog("open");
	});
	
	$(document).on('click', '#mail-plus', function(event) {
		event.preventDefault();
		
		$('.plus-div').before('<div class="input-mail-div"><span class="input-mail-index">' + index + '</span><input type="text" class="input-mail" id="input-mail" autocomplete="off" placeholder="codeforest2020@gmail.com"><span class="mail-delete" id="mail-delete"><i class="mail-delete fas fa-minus-circle"></i></span>');
		
		index++;
	});
	
	$(document).on('click', '#mail-delete', function(event) {
		event.preventDefault();
		
		var ind = $(this).parent().children().eq(0).text();
		
		if(index == 2) {
			alert('1개 이상은 입력하셔야 합니다');
			return false;
		}
		$(this).parent().remove();
		
		var initIndex = document.getElementsByClassName('input-mail-index');
		
		ind = Number(ind) + 1;
		for(var i = ind; i < index; i++) {
			initIndex[i - 2].textContent = i - 1;
		}
		index--;
	});
	
	$("#mail").change(function(){
        if($(this).is(":checked")){
        	$('#mail-th').text('메일');
        	var kwd = $('#kwd').val();
        	mailChecked = true;
        	originList('1', kwd);
        } else{
        	$('#mail-th').text('내보내기');
        	var kwd = $('#kwd').val();
        	mailChecked = false;
        	originList('1', kwd);
        }
    });
	
	$("#mail-span").click(function(){
		$('#mail').trigger('click');
    });
	
	$(document).on('keyup', '#input-mail', function(event) {
		var email = $(this).val();
		
		if(email == '') {
			$(this).css('background-image', '');
			return false;
		}
		
		if(!checkEmail(email)) {
			$(this).css('background-image', 'url("/forest12/assets/images/user/cross.png")');
			rightPandan = false;
		} else {
			$(this).css('background-image', '');
			rightPandan = true;
		}
	});
	
//------------------------------------------- 끝부분	
});
</script>
    
</head>
<body>
	<div class="wrong" id="send-mail" style="display: none">
		<p class="wrong-ptag">메일을 전송중입니다</p>
	</div>
    <c:import url="/WEB-INF/views/include/mypage-header.jsp" />
    <div class="container">
        <div class="quizlist">
            <div class="line">
                <h4>문제 관리</h4>
            </div>
            <div class="search">
                <input type="text" id="kwd" name="kwd" placeholder="Search.." onKeyDown="onKeyDown();" autoComplete="off">
                <input type="button" id="search" value="검색" >
                <input type="checkbox" class="mail" id="mail"> <span class="mail-span" id="mail-span">메일 보내기</span>
            </div>
            <br>
            <table class="quiz-table">
               <thead>
                   <tr>
                       <th width="10%">번호</th>
                       <th width="46%">제목</th>
                       <th width="10%">조회수</th>
                       <th width="10%">추천수</th>
                       <th width="10%">수정하기</th>
                       <th width="10%" id="mail-th">내보내기</th>
                       <th width="10%">삭제</th>
                   </tr>
                </thead>
            </table>
            
            <br>
        </div>

    </div>
    
    <div id="dialog-delete" title="문제 모음 삭제" style="display: none">
       <p>
          <span class="ui-icon ui-icon-alert" style="float: left; margin: 4px 12px 0 0;">   
          </span>
          해당 문제 모음을 삭제하시겠습니까?
       </p>
       <form>
          <input type="hidden" id="hidden-no" value="">
          <input type="submit" tabindex="-1" style="position:absolute; top:-1000px">
       </form>
    </div>
    
    <div id="dialog-delete-sp" title="서브 문제 삭제" style="display: none">
       <p>
          <span class="ui-icon ui-icon-alert" style="float: left; margin: 12px 12px 20px 0;">   
          </span>
          해당 서브 문제를 삭제하시겠습니까?
       </p>
       <form>
          <input type="hidden" id="hidden-sp-no" value="">
          <input type="hidden" id="hidden-table-class" value="">
          <input type="submit" tabindex="-1" style="position:absolute; top:-1000px">
       </form>
    </div>
    
    <div class="problem-list" title="문제 푼 사람 리스트" style="display: none">
       <input type="hidden" id="hidden-title" value="">
       <div class="check-box">
          <label><input class="box-component" type="checkbox" name="problem-list-table" value="name" checked>이름</label>
          <label><input class="box-component" type="checkbox" name="problem-list-table" value="email" checked>이메일</label>
          <label><input class="box-component" type="checkbox" name="problem-list-table" value="nickname" checked>닉네임</label>
          <label><input class="box-component" type="checkbox" name="problem-list-table" value="try-count" checked>시도횟수</label>
          <label><input class="box-component" type="checkbox" name="problem-list-table" value="lang" checked>언어</label>
          <label><input class="box-component" type="checkbox" name="problem-list-table" value="solve-time" checked>해결시간</label>
       </div>
       <table class="problem-list-table rtable">
          <tr>
         		<th class="discard" id="go-codetree discard">코드보기</th>
               <th id="name">이름</th>
               <th id="email">이메일</th>
               <th id="nickname">닉네임</th>
               <th id="try-count">시도횟수</th>
               <th id="lang">언어</th>
               <th id="solve-time">해결시간</th>
            </tr>
       </table>
    </div>
    <div id="mail-dialog" title="응시자 메일" style="display:none" >
		<fieldset class="mail-fieldset">
		    <div class="content-div">
			    <span for="name" class="content-span">보내고자 하는 이메일을 입력해주세요.</span>
			</div>
		</fieldset>
	    <div id="input-mail-div">
	    	<span class="input-mail-index">1</span>
	    	<input type="text" class="input-mail strange" id="input-mail" autocomplete="off" placeholder="codeforest2020@gmail.com">
	    	<span class="mail-delete strange-span" id="mail-delete"><i class="mail-delete fas fa-minus-circle"></i></span>
	    </div>
	    <div class="plus-div">
	    	<span class="mail-plus" id="mail-plus">+</span>
	    </div>
	</div>
    <c:import url="/WEB-INF/views/include/footer.jsp" />
</body>

</html>