<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib uri="dbfound-tags" prefix="d"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
	<head>
		<d:includeLibrary />
	</head>
	
	<script type="text/javascript">
		function query() {
			jobGrid.query();
		}
		
		function reset() {
			queryForm.form.reset();
		}
		
		function openAddWindow(){
			url="${basePath}modules/job/newJob.jsp";
			location.href=url;
			//DBFound.open("update_window","作业新增",650,320,url,function(){jobGrid_ds.reload();});
		}

		function gotoDetail(value,meta,record){
			   return "<a href = javaScript:openUpdateWindow('"+record.json.header_id+"','"+record.json.status_code+"')>"+value+"</a>";
	    }

		function openUpdateWindow(id,status){
			 var url;
			 if (status=='NEW'){
				 url = "modules/job/updateJob.jsp?header_id="+id;
				 DBFound.open("update_window","作业明细",735,350,url,function(){jobGrid_ds.reload();});
			 }else if(status=='CHECK'){
				 url = "${basePath}"+"modules/job/checkJob.jsp?header_id="+id;
				 DBFound.open("check_window","作业明细",890,505,url,function(){jobGrid_ds.reload();});
			 }else{
				 url = "${basePath}"+"modules/job/showCheckedJob.jsp?header_id="+id;
				 DBFound.open("check_window","作业明细",890,505,url);
			 }
		}

		function finish(value,meta,record){
			var onclick = "finishSubmit('"+record.json.header_id+"')";
		   return '<img alt="审批" style="cursor:pointer" height="15" onclick='+onclick+' src="${basePath}DBFoundUI/images/check.png">';
        }

        function finishSubmit(header_id){
            param = {header_id:header_id};
            $D.request("job/jobControl.execute!check",param,finishCallBack,true);
        }
        
        function finishCallBack(resObj,response,action){
            if(resObj.success==true){
                $D.showMessage(resObj.message,query);
            }else{
            	 $D.showError(resObj.message);
            }
        }

        function upAttuchement(value,meta,record){
 		   return "<a href = javaScript:openAttWindow('"+record.json.header_id+"','"+record.json.status_code+"')>附件("+value+")</a>";
        }
        
        function openAttWindow(id,status){
           var url;
		   if (status=='NEW'){
			   url="upload.jsp?pk_value="+id+"&table_name=job_headers";
			   DBFound.open("att_window","附件上传",690,395,url,refreshFileNum);
		   }else{
			   url="uploadShow.jsp?pk_value="+id+"&table_name=job_headers";
			   DBFound.open("att_show_window","附件查看",690,370,url);
		   }
        }

        function refreshFileNum(){
            var json = jobGrid.getCurrentRecordData();
			$D.request({
				url:"upload.query!count?pk_value="+json.header_id+"&table_name=job_headers",
				callback:function(res){
					var num = res.datas[0].total_num;
					jobGrid.setCurrentRecordData({att_num:num});
				}
			});
    	}

        function resetCourse(dom,field){
			course_ds.baseParams={class_id:field.data.class_id};
			var course_cb=Ext.getCmp("course_cb").setValue(null);
			course_ds.load();
		}
	</script>
	<body>
	    <d:initProcedure>
		    <d:dataSet id="class_ds" modelName="fnd/class" queryName="combo" />
		    <d:dataSet id="course_ds" modelName="fnd/course" queryName="add_combo" loadData="false" fields="course_name,course_id" />
		    <d:dataSet id="statusStore" modelName="job/jobStatus" queryName="combo" />
		</d:initProcedure>
	
		<d:form id="queryForm" title="作业工作台" labelWidth="90">
			<d:line columnWidth="0.33">
				<d:field name="title" editor="textfield" prompt="作业题目">
				   <d:event name="enter" handle="query"/>
				</d:field>
			    <d:field name="class_id" options="class_ds" valueField ="class_id" displayField="class_name" editor="combo" prompt="班级" >
			      <d:event name="select" handle="resetCourse"></d:event>
			    </d:field>
			    <d:field id="course_cb" name="course_id" options="course_ds" valueField ="course_id" displayField="course_name" editor="combo" prompt="课程选择" />
			</d:line>
			<d:line columnWidth="0.33">
			    <d:field name="status_code" editor="combo" options="statusStore" displayField="status_name" valueField="status_code" prompt="状态" />
			    <d:field name="timefrom" editor="datefield" prompt="创建日期从" />
				<d:field name="timeto" editor="datefield" prompt="创建日期到" />
			</d:line>
		</d:form>
		<d:buttonGroup>
			<d:button id="query" title="查询" click="query" />
			<d:button title="重置" click="reset" />
		</d:buttonGroup>
		<d:grid id="jobGrid" title="作业列表" height="350" queryForm="queryForm" model="job/jobHeader" autoQuery="true" >
			<d:toolBar>
				<d:gridButton type="add" beforeAction="openAddWindow" />
				<d:gridButton action="job/jobControl.execute!submit" afterAction="query" icon="DBFoundUI/images/email.png" title="布置"/>
				<d:gridButton action="job/jobControl.execute!check" afterAction="query" icon="DBFoundUI/images/check.png" title="审批"/>
				<d:gridButton action="job/jobControl.execute!finish" afterAction="query" icon="DBFoundUI/images/disk.png" title="完成"/>
			</d:toolBar>
			<d:columns>
			    <d:column name="title" renderer="gotoDetail"  prompt="作业题目" width="140" />
			    <d:column name="att_num" align="center" renderer="upAttuchement" prompt="附件" width="70" />
				<d:column name="class_name" width="140" prompt="班级" />
				<d:column name="course_name" width="140" prompt="学科选择" />
				<d:column name="status_name"  width="60"  prompt="状态" />
			    <d:column name="end_time"  width="90" prompt="完成时间" />
				<d:column name="teacher_name"  prompt="布置老师" width="100" />
				<d:column name="create_date" prompt="创建时间" width="90" />
				<d:column name="finish" align="center" renderer="finish" prompt="审批" width="60" />
			</d:columns>
		</d:grid>
	</body>
</html>
