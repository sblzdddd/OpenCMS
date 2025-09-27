import 'package:flutter/material.dart';


String convertColorToCss(Color color) {
  return 'rgba(${color.r*255}, ${color.g*255}, ${color.b*255}, ${color.a})';
}

String webCmsStyle(BuildContext context) {
  final darkCardColorCss = convertColorToCss(Theme.of(context).colorScheme.surfaceContainerLow);
  final primaryColorCssTransparent = convertColorToCss(Theme.of(context).colorScheme.primary.withValues(alpha: 0.1));
  final cardHeadColorCss = convertColorToCss(Theme.of(context).colorScheme.surfaceContainerHigh);
  final primaryColorCss = convertColorToCss(Theme.of(context).colorScheme.primary);
  final onSurfaceCss = convertColorToCss(Theme.of(context).colorScheme.onSurface);
  final surfaceColorCss = convertColorToCss(Theme.of(context).colorScheme.surface);
return '''
var ensure2 = function() {
          var s = document.createElement('style');
          s.id = 'ocms-css-inject';
          s.type = 'text/css';
          s.appendChild(document.createTextNode(`
.jfk-bubble.gtx-bubble, .captcheck_answer_label > input + img, span#closed_text > img[src^="https://www.gstatic.com/images/branding/googlelogo"], span[data-href^="https://www.hcaptcha.com/"] > #icon, #bit-notification-bar-iframe, ::-webkit-calendar-picker-indicator {
    filter: invert(100%) hue-rotate(180deg) contrast(90%) !important;
}
html, .ant-layout,
.ant-descriptions-view td {
    background-color: transparent !important;
}
html {
    color-scheme: dark !important;
}
html, body, input, textarea, select, button, dialog {
    background-color: transparent
}
input:-webkit-autofill,
textarea:-webkit-autofill,
select:-webkit-autofill {
    background-color: #404400 !important;
    color: #e8e6e3 !important;
}
::-webkit-scrollbar {
    background-color: #202324;
    color: #aba499;
}
::-webkit-scrollbar-thumb {
    background-color: #454a4d;
}
::-webkit-scrollbar-thumb:hover {
    background-color: #575e62;
}
::-webkit-scrollbar-thumb:active {
    background-color: #484e51;
}
::-webkit-scrollbar-corner {
    background-color: #181a1b;
}
::selection {
    background-color: #004daa !important;
    color: #e8e6e3 !important;
}
::-moz-selection {
    background-color: #004daa !important;
    color: #e8e6e3 !important;
}

.site-layout-content,
.ant-col, .ant-table-cell-row-hover,
.ant-input-outlined,
.ant-table-placeholder,
.ant-list.ant-list-sm.ant-list-split,
.ant-layout-header .ant-menu {
  background-color: transparent !important;
}

.ant-layout-header .ant-menu.ant-menu-root.ant-menu-horizontal.ant-menu-dark {
  display: none!important;
}

.ant-card-bordered, .ant-breadcrumb, .sidebar-link:hover, .ant-menu,
.navbar-inner, .list-group-item,
.main_tops, .red {
  background-color: $darkCardColorCss !important;
  border: none !important;
}

.ant-avatar.ant-avatar-square, .ant-menu-item-selected {
  background-color: $primaryColorCssTransparent !important;
  border: none !important;
}

.ant-typography, .ant-card-head-title, :where(.css-1ifgnse) a,
.ant-breadcrumb-separator, .ant-breadcrumb-link,
.ant-list-item-meta-description, .ant-dropdown-menu-title-content,
.ant-descriptions-item-content, .ant-menu-title-content,
.ant-picker-input,
.ant-table-thead .ant-table-cell,
.ant-collapse-header-text, p,
.ant-empty-description,
.ant-table-row>.ant-table-cell>div>div>div,
.ant-list-item,
.ant-btn-color-default, .ant-btn,
.ant-input-group, .ant-input-affix-wrapper,
.ant-radio-button-wrapper, label,
section#services .align .sev_icon, .gray_div h2,
.ant-table-cell {
  color: $onSurfaceCss !important;
}

.ant-typography a, .ant-typography strong, 
:where(.css-1ifgnse).ant-btn-variant-link, 
.anticon,
.ant-list-item-meta-title > a,
.ant-card-extra > a,
.ant-descriptions-item-label,
.ant-menu-item-selected > .ant-menu-title-content,
.cell-title, .ant-modal-title,
.ant-list-item-meta-title,
.ant-table-row>.ant-table-cell>div>div>div>span {
  color: $primaryColorCss !important;
}

.ant-btn-primary, .ant-btn-variant-solid {
  background-color: $primaryColorCssTransparent !important;
  box-shadow: none !important;
}

.ant-menu-item:hover::after, .ant-menu-item-selected::after {
  border-bottom-color: $primaryColorCss !important;
}

.ant-popover-arrow, .ant-dropdown-arrow {
  --antd-arrow-background-color: $surfaceColorCss !important;
}

.ant-card-head, .ant-layout-header, .ant-layout-footer,
.ant-table-thead .ant-table-cell,
:where(.css-6yzmry).ant-table-wrapper .ant-table-tbody .ant-table-row >.ant-table-cell-row-hover,
.ant-collapse-content,
.ant-btn-color-default,
.ant-radio-button-wrapper,
.ant-picker {
  background-color: $cardHeadColorCss !important;
  border: none !important;
}

body {
  background-color: transparent !important;
}

.ant-layout-header {
  overflow: hidden !important;
}

.span6, .span12 {
  background-color: $primaryColorCssTransparent !important;
}

.ant-radio-button-wrapper-checked {
  color: $primaryColorCss !important;
  border-color: $primaryColorCss !important;
  border: 1px solid $primaryColorCss !important;
}
.ant-radio-button-wrapper-checked::before {
  color: $primaryColorCss !important;
  background-color: $primaryColorCss !important;
}

.ant-popover-inner, .ant-dropdown-menu,
.ant-picker-panel-container,
.ant-select-dropdown, .ant-select-outlined,
.ant-select-selector, .ant-modal-content, .ant-modal-header,
.ant-table {
  background-color: $surfaceColorCss !important;
}

.ant-table-container {
  border: none !important;
}

li[data-menu-id="rc-menu-uuid-54234-2-logout"],  {
  display: none !important;
}

.ant-card-body>.ant-flex.css-1ifgnse.ant-flex-justify-space-between>.ant-space.css-1ifgnse.ant-space-vertical.ant-space-gap-row-small.ant-space-gap-col-small>.ant-space-item:nth-child(4) {
  display: none !important;
}

.ant-btn-link {
  background-color: transparent !important;
}

/* old cms */

.tabs {margin-top: 0.3em;}
.tabs td{background: $darkCardColorCss !important; line-height: 1.15em; height: 2.15em;}
.tabs td.on{background: $primaryColorCssTransparent !important; line-height: 1.15em; height: 2.15em;}


.certification-div{width:100%; height:2.5em; margin:0px auto 2px auto;background-color: $cardHeadColorCss!important; background-image: none !important; }
.animated{width:90%;height:2.5em;line-height:2.5em;text-align:center;font-weight: 10;color:#777;float:right;}
.animated-create{width:100%;height:2.5em;line-height:2.5em;text-align:center;font-weight: 10;color:#fff;}

.btn {background-color: $cardHeadColorCss !important;}
.submenu {background-color: $cardHeadColorCss !important;}

/*****修改样式**********/

.ctbody_w{border:1px solid #B8B8B8;height:auto}
.ctbody1{border:1px solid #B8B8B8;width:748px;height:auto}
.main1{width:960px;margin:0px auto;}
.rightbar1{width:749px;float:left;}
#leaders1{background:$darkCardColorCss;width:730px;padding:8px 0px 6px!important;padding:8px 0 0 0;}
#leaders1  a:link{text-decoration:none;color:#ffffff;}
#leaders1 a:visited{text-decoration:none;color:#ffffff;}
#leaders1 a:hover{text-decoration:underline;color:#ffffff;}

.rightbar1_w{width:749px;float:left;}
#leaders1_w{background:$darkCardColorCss;width:730px;padding:8px 0px 6px!important;padding:8px 0 0 0;}
#leaders1_w  a:link{text-decoration:none;color:#ffffff;}
#leaders1_w a:visited{text-decoration:none;color:#ffffff;}
#leaders1_w a:hover{text-decoration:underline;color:#ffffff;}

.main1_w100{width:100%;margin:0px auto;text-align:center;}
.main1_w80{width:80%;margin:0px auto;text-align:center;}
.rightbar1_w100{width:80%;}
#leaders1_w100{background:$darkCardColorCss;width:80%;padding:8px 0px 6px!important;padding:8px 0 0 0;}
#leaders1_w100  a:link{text-decoration:none;color:#ffffff;}
#leaders1_w100 a:visited{text-decoration:none;color:#ffffff;}
#leaders1_w100 a:hover{text-decoration:underline;color:#ffffff;}

.jqtext_viz1{float:left;width:560px;line-height:22px;font-size:12px;margin-top:30px;border-right:1px solid #CDCBCB;padding-right:10px;padding-left:10px;}
.dsiyse1{background:#F7F6F7;width:652px;}
.fafea1{width:652px;background:url('/static/images/uyc_bj.gif') no-repeat;}
.capyht1{width:590px;margin-left:18px;margin-bottom:5px;}
.allexam_cor1{margin-bottom:10px;background:#eeeeee;padding-left:60px;padding-top:0px !important;padding-top:5px;padding-bottom:0px !important;padding-bottom:5px;}
.cours_paiu1{position:relative;top:230px;padding-left:640px !important;padding-left:633px;}
.cours_paiu11{position:relative;top:125px;padding-left:640px !important;padding-left:633px;}
.part_uae1{margin-bottom:10px;background:$primaryColorCssTransparent;line-height:25px;padding-left:5px;border-top:1px solid $primaryColorCss}
.part_cae1{margin-bottom:10px;background:$primaryColorCssTransparent;line-height:25px;padding-left:5px;border-top:1px solid $primaryColorCss;}
.part_cefbr{margin-bottom:40px;}
.jqtext_sul1{float:left;width:705px;line-height:22px;font-size:12px;margin-top:10px;}
.jqtext_xt1{float:left;width:560px;line-height:22px;font-size:12px;margin-top:30px;padding-left:10px;margin-right:10px !important;margin-right:5px;}
.dgesep_xt1{float:left;width:158px;font-size:12px;line-height:22px;color:#868383;margin-top:30px;border-left:1px solid #CDCBCB;margin-left:5px;}
.fegse1{background:#F7F6F7;width:520px;}
.allexam1{margin-top:15px;margin-bottom:10px;background:#eeeeee;padding-left:60px;padding-top:0px !important;padding-top:5px;padding-bottom:0px !important;padding-bottom:5px;}
.ytafeef1{width:650px;line-height:25px;}
.mayc_pave{position:relative;top:275px;padding-left:640px !important;padding-left:633px;}
.fegses1{background:#eeeeee;width:520px;}
.jqtext_vis{float:left;width:560px;line-height:22px;font-size:12px;margin-top:10px;border-right:1px solid #CDCBCB;padding-right:20px;}
.video1{float:left;background:#F9F6F6;width:109px;line-height:20px;padding:3px;margin-right:18px;padding-bottom:0;border:1px solid #E1DDDD;margin-bottom:15px;position:relative;left:17px;}
.video_bt1{float:left;background:#D9D2D2;width:109px;line-height:20px;padding:3px;margin-right:18px;padding-bottom:0;border:1px solid #C1BFBF;margin-bottom:10px;margin-top:20px;position:relative;left:17px;}
.vid_bj1{height:100%;background:#eeeeee url('/static/images/lect_pic03.jpg') repeat-x top;margin-bottom:10px;width:400px;}
.maraes1{margin-bottom:20px;width:396px;height:234px;margin-left:15px;}
.zly_mae1{width:686px;white-space:nowrap;margin-right:5px;position:relative;top:-10px;padding:auto;margin:auto}
.gagea1{float:left;margin-left:50px;line-height:20px;position:relative;left:-30px;top:25px;margin-bottom:20px;width:170px;}
.jqtext_x1{float:left;width:503px;line-height:22px;font-size:12px;margin-top:10px;padding-right:4px;margin-left:2px;}
.dgesex{float:left;width:180px;line-height:22px;margin-top:10px;position:relative;left:20px;}
#calendardiv{width:100px;}
.studywvt{float:right;padding-right:20px;}
.syaiyve{width:50px;height:24px;}

/* for exaport */
.export-options-block{border:5px solid #B2DFEE;width:100%;padding:2px;background-color:#E0FFFF;}
.export-options-block li{float:left;line-height:35px;height:35px;border:1px solid #FFFFFF;min-width:98px;cursor:default;} 
.un-chosen{background:url(/static/images/pic/checkbox_empty_20.png) no-repeat left;padding-left:25px;background-color:#E0FFFF;}
.chosen{background:url(/static/images/pic/checkbox_full_20.png) no-repeat left;padding-left:25px;font-weight:bold;background-color:#B2DFEE;}
.un-chosen:hover{background-color:#B2DFEE;}
.get_more_span{background:url(/static/images/rect_right.png) no-repeat right;display:inline-block;width:115px;height:25px;line-height:25px;padding-top:5px;border:1px solid #fff;background-color:#E0FFFF;cursor:default;}
.get_more_span_on {background:url(/static/images/rect.gif) no-repeat right;display:inline-block;width:115px;height:25px;line-height:25px;padding-top:5px;border:1px solid #B2DFEE;background-color:#B2DFEE;cursor:default;}

/*survey*/
.survey-table-content {width:100%;height:auto;;}
.survey-table-content tr{width:100%;border-bottom:1px solid #0000;height:auto;}
.survey-table-content td{height:auto;border-bottom:1px solid #87CEFA;line-height:20px;font-size:12px;text-align:left;}

.survey-table-content tr.head td{border-top:1px solid #B9D3EE;font-weight:bold;background:#CAE1FF;}
.survey-table-content .order{width:25px;border-right:1px solid #B9D3EE;}
.survey-table-content .name{width:25px;border-right:1px solid #B9D3EE;}
.survey-table-content .position{width:50px;border-right:1px solid #B9D3EE;}
.survey-table-content .job{width:50px;border-right:1px solid #B9D3EE;}
.survey-table-content .grade{width:30px;border-right:1px solid #B9D3EE;}
.survey-table-content .policy{width:auto;margin-left:15px;}
/*university application*/
.order_span{position:relative;top:-10px;z-index:199;}
.teacher-img{vertical-align:middle;border:0px;position:relative;top:-10px;}
#data-list-block {width:100%;height:auto;text-align:center;}
#data-list-block ul,li{padding:0px;}
#data-list-block li{float:left;height:50px;}


#data-list-block .order{width:30px;}
#data-list-block .period{width:50px;}
#data-list-block .pic{width:55px;}

#data-list-block .ox-cam{width:55px;}
#data-list-block .u-option{width:28px;}
#data-list-block .ucas-option{width:32px;}
#data-list-block .u-option-other{width:120px;}
#data-list-block .sbj{width:230px;}
#data-list-block .opt{width:30px;}
#data-list-block .tutor{width:150px;}
#data-list-block .ucas-option-other{width:150px;}
#data-list-block .us-option-other{width:150px;}
#data-list-block .choices{width:65px;}
#data-list-block .us-option{width:50px;}
#data-list-block .us-option-s{width:40px;}
#data-list-block .us-tutor{width:150px;}
#data-list-block .ucas-tutor{width:180px;}
#data-list-block .ucas-tutor-info{width:350px;}

#data-list-block .ul_head {background-color:gray;height:45px;line-height:45px;}
#data-list-block .ul_head .student{width:110px;}
#data-list-block .ul_head .ucas-student{width:165px;}
#data-list-block .ul_head .us-student{width:145px;}

#data-list-block .ul_details{width:100%;height:auto;min-height:30px;border-top:2px solid #D1EEEE;border-bottom:1px solid #D1EEEE;}
#data-list-block .ul_details li{font-size:12px;line-height:30px;}
#data-list-block .ul_details:hover{background-color:#E6E6FA;}
#data-list-block .ul_details .order{padding-top:5px;line-height:35px;font-size:16px;color:red;}
#data-list-block .ul_details .period{width:50px;line-height:20px;}
#data-list-block .ul_details .pic{line-height:50px;text-align:left;}
#data-list-block .ul_details .student{width:55px;line-height:18px;text-align:left;overflow:visible;white-space:nowrap;text-overflow:ellipsis;}
#data-list-block .ul_details .us-student{width:90px;line-height:18px;text-align:left;overflow:visible;white-space:nowrap;text-overflow:ellipsis;}
#data-list-block .ul_details .ucas-student{width:100px;line-height:18px;text-align:left;overflow:visible;white-space:nowrap;text-overflow:ellipsis;}
#data-list-block .ul_details .tutor{line-height:50px;text-align:left;overflow:visible;white-space:nowrap;text-overflow:ellipsis;}
#data-list-block .ul_details .ucas-tutor{line-height:50px;text-align:left;overflow:visible;white-space:nowrap;text-overflow:ellipsis;}
#data-list-block .ul_details .us-tutor{line-height:50px;text-align:left;overflow:visible;white-space:nowrap;text-overflow:ellipsis;}
#data-list-block .ul_details .ucas-tutor-info{line-height:50px;text-align:center;overflow:visible;white-space:nowrap;text-overflow:ellipsis;}
#data-list-block .ul_details .teacher img{height:18px;width:15px;vertical-align:middle;}
#data-list-block .ul_details .ox-cam{line-height:55px;padding-top:5px;}
#data-list-block .ul_details .u-option{line-height:50px;padding-top:5px;}
#data-list-block .ul_details .us-option{line-height:50px;padding-top:5px;}
#data-list-block .ul_details .us-option-s{line-height:50px;padding-top:5px;}
#data-list-block .ul_details .u-option img{vertical-align:middle;}
#data-list-block .ul_details .ucas-option{width:32px;line-height:50px;padding-top:5px;}
#data-list-block .ul_details .choices{width:65px;line-height:55px;padding-top:5px;}
#data-list-block .ul_details .u-option-other{line-height:15px;padding-top:5px;}
#data-list-block .ul_details .ucas-option-other{line-height:15px;padding-top:5px;}
#data-list-block .ul_details .sbj{line-height:15px;padding-top:1px;text-align:left;font-size:12px;}
#data-list-block .ul_details .opt{font-size:10px;}

/*referral comment*/
.rf_comment_td{text-align:left;height:20px; }
.rf_comment_td:hover{background-color:#CFCFCF;}
.rf_comment_td span{float:left;display:-moz-inline-box;display:inline-block;height:25px;line-height:25px;text-align:left;}
/*CMS管理奖学金*/
.file_pic_block{width:150px;height:150px;line-height:18px;border:2px solid #E1DDDD;background-color:#F2F2F2;display: inline-block;margin: 5px; vertical-align: top}
.file_pic_block_title{width:150px;height:20px;line-height:18px;text-align:center;}
.file_pic_block_img{width:150px;height:100px;line-height:18px;text-align:center;}
.file_pic_block_check{width:150px;height:20px;line-height:18px;text-align:center;}

/*leave cover*/
/*LEAVERECORD_CHOICES=((0, '-Leave Kind-'),(1, 'Sick Leave'),(2, 'Personal Leave'),(3, 'College Reason'),(4, 'Trip'),(5, 'Conference/Training'),(6, 'IA Trip'),)*/
.lr_0{color:#ffffff;} .lr_1{color:#EEC900;} .lr_2{color:blue;} .lr_3{color:#FFC0CB;} .lr_4{color:#008B00;} .lr_5{color:#4B0082;} .lr_5{color:#BA55D3;} .lr_6{color:#9ACD32;}
.lr_bg_0{background-color:#ffffff;color:#ffffff;} .lr_bg_1{background-color:#EEC900;color:#ffffff;} .lr_bg_2{background-color:blue;color:#ffffff;} .lr_bg_3{background-color:#FFC0CB;color:#ffffff;} .lr_bg_4{background-color:#008B00;color:#ffffff;} .lr_bg_5{background-color:#4B0082;} .lr_bg_5{background-color:#BA55D3;color:#ffffff;} .lr_bg_6{background-color:#9ACD32;color:#ffffff;}

/*
{%ifequal kq.color 'yellow'%}style='color:black;'{%else%}{%ifequal kq.color 'white'%}style='color:black;'{%else%}{%ifequal kq.color 'pik'%}style='color:black;'{%else%}style='color:white;'{%endifequal%}{%endifequal%}{%endifequal%}
*/
/* new style for attendance */

.tips{background-color:#548B54;border:2px solid #F99C00;color:#ffffff;text-align:center;width:200px;height:35px;line-height:33px;position:fixed;left:0px;right:0px;top:0px;margin-left:auto;margin-right:auto;z-index:1000;}
.edit_icon{position: absolute;top:-5px;right:-5px;float:right;}
.att_b{background:$primaryColorCss;color:#ffffff;padding:0 3px;line-height:14px;text-align:center;margin-right:3px;}
.att_remark{border:1px solid #CAE1FF;background:#E0FFFF;color:#0000;text-align:center;}
.att_remark:hover{border:1px solid #9FB6CD;}
/*  -1缺勤,0出勤，1迟到,2旷课,4病假,5事假,6school  */
.attkind_-1{background-color:#ffffff; color:#000000;}
.attkind_0{background-color:green; color:#000000;}
.attkind_1{background-color:#000000; color:#ffffff;}
.attkind_2{background-color:#663300; color:#ffffff;}
.attkind_3{background-color:yellow; color:$primaryColorCss;}
.attkind_4{background-color:blue; color:#ffffff;}
.attkind_5{background:#FFC0CB; color:#000000;}

.attkind_-1 .course{color:#000000;}
.attkind_0 .course{color:#ffffff;}
.attkind_1 .course{color:#ffffff;}
.attkind_2 .course{color:#ffffff;}
.attkind_3 .course{color:#000000;}
.attkind_4 .course{color:#ffffff;}
.attkind_5 .course{color:#000000;}

.attkind_-1 .remark{color:#000000;display:none;}
.attkind_0 .remark{color:#ffffff;display:none;}
.attkind_1 .remark{color:#ffffff;}
.attkind_2 .remark{color:#ffffff;}
.attkind_3 .remark{color:#000000;}
.attkind_4 .remark{color:#ffffff;}
.attkind_5 .remark{color:#000000;}


.attfont_-1{color:#ffffff; }
.attfont_0{color:green; }
.attfont_1{color:#000000;}
.attfont_2{color:#663300;}
.attfont_3{color:yellow;}
.attfont_4{color:blue;}
.attfont_5{color:#FFC0CB;}

.att_bg_-1{background-color:#000000;}
.att_bg_0{background-color:#ffffff;}
.att_bg_1{background-color:#000000;}
.att_bg_2{background-color:#663300;}



.psat_block li{height:30px;line-height:30px;padding:1px;}
.psat_block .main_title{color:#636DEA;font-size:16px;}
.psat_block .main_value{color:#2A6D92;font-size:20px;padding-left:10px;}
.psat_block .psat_tips{color:#CCCCCC;font-size:12px;padding-left:30px;}
.psat_block .sub_title{color:#CC0000;font-size:16px;}
.psat_block .sub_block{list-style:disc;margin-left:30px;}
.psat_block .sub_sbj{color:#000000;font-size:14px;}
.psat_block .sub_sbj_value{color:#CD2626;font-size:16px;padding-left:10px;}


#MAIN_POP_DIV_HTML{display:none; position:absolute;font-size:6pt;width:750px; height:500px;overflow-x:scroll;background:#D1EEEE;color:#666666; padding:0px 10px 5px 0px; border:1px solid #B9D3EE;line-height:20px;  display:none; z-index:12001; _top:expression(eval(document.compatMode && document.compatMode=='CSS1Compat') ? documentElement.scrollTop + (document.documentElement.clientHeight-this.offsetHeight)/2 :/*IE6*/
 document.body.scrollTop + (document.body.clientHeight - this.clientHeight)/2);/*IE5 IE5.5*/}
.STUDENT_TIMETABLE {width:100%;}
.STUDENT_TIMETABLE  ul li{float:left;width:115px;font-size:10pt;height:20px;line-height:11px;}
.STUDENT_TIMETABLE  li a{ font-size:8pt;}
.STUDENT_TIMETABLE  li{ border-right:1px solid #B9D3EE;}
.STUDENT_TIMETABLE  ul { border-bottom:1px solid #B9D3EE;}
.STUDENT_TIMETABLE  ul.head{position:fixed;font-weight:bold;text-align:center;background:#EECFA1;}
.STUDENT_TIMETABLE  ul.head li{background:#B9D3EE;font-size:10pt;}
.STUDENT_TIMETABLE  ul.first{padding-top:38px;}
.STUDENT_TIMETABLE  li.peirod{ width:30px;}
.close_pop_window {position:fixed;width:1px;height:1px;left:1215px;}
/*html { filter:progid:DXImageTransform.Microsoft.BasicImage(grayscale=1); } */
textarea{margin:0px;padding:2px;line-height:20px;border:1px solid #cccccc;background:#ffffff;font-size:12px;}
select{margin:0px;border:1px solid #44AAFF;background:#EAF4FF;padding:1px;}
select{border: solid 1px #ccc;appearance: none;/*清除select下拉框默认样式*/-moz-appearance: none;-webkit-appearance: none;padding-right: 14px;/*为下拉小箭头留出一点位置，避免被文字覆盖*/background: url("/static/images/arrow_down.png") no-repeat scroll right center transparent !important;/*自定义图片覆盖原有的下三角符号*/}
select::-ms-expand {display: none;/*清除IE默认下拉按钮，但是测试发现IE10以上有效，IE8，9默认下拉按钮仍旧存在*/}
table{width:100%;font-size:12px}
td{padding:0px 0px;text-align:center}
th{padding:0px 0px;background:$cardHeadColorCss;text-align:center; color: $onSurfaceCss;}
.hid{display:none;}
.hand{cursor:pointer;}
.block{display:block;}
.del{text-decoration:line-through;}
/*字体划线*/
.line-through{TEXT-DECORATION: line-through;} /* 刪除線 */ .overline{TEXT-DECORATION: overline;} /* 上划线 */ .underline{TEXT-DECORATION: underline;} /* 下划线 */
.fitalic{font-style:italic;}
/***********************滑过链接鼠标变成手型****************/

/***********************超出文体宽度隐藏文字****************/
.yqgao{overflow:hidden;text-overflow:ellipsis; white-space:nowrap;}

/***********************超出文体宽度隐藏文字(加在ＤＩＶ上面)****************/
.vvv{width:100%;word-break:keep-all;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
/*************************水平居中****************/
.vertical{text-align:center ;}
/******确定样试******/
.submit{border-width:0px; padding: 2px 0 0 0;font-size: 12px; background:url("/static/images/input_bg3.gif");width: 48px;height:20px;cursor:pointer;}
.submit_big{border-width:0px; padding: 2px 0 0 0;font-size: 12px; color:#666666; background:url("/static/images/input_bg4.gif");width: 70px;height:30px;cursor:pointer;}
.submits{border-width:0px; padding: 2px 0 0 0;font-size: 12px; background:url("/static/images/input_bg4.gif");width: 80px;height:20px;cursor:pointer;}
.submit_tbig{border-width:0px; padding: 2px 0 0 0;font-size: 12px; background:url("/static/images/input_bg5.gif");width: 80px;height:29px;cursor:pointer;}
.submit_tbig_gray{border-width:0px; padding: 2px 0 0 0;font-size: 12px; background:url("/static/images/input_bg5_gray.gif");width: 80px;height:29px;cursor:pointer;}
.submit_a{border:1px solid #DC6E6E; padding: 5px 5px 5px 5px;font-size: 12px; background:#FEEFEF;cursor:pointer;}
.submit_lbig{border-width:0px; padding: 2px 0 0 0;font-size: 12px; background:url("/static/images/input_bg6.png");width: 80px;height:29px;cursor:pointer;}

/*************************字体样式****************/	
strong {color: $primaryColorCss;}
span, div {color: $onSurfaceCss;}
.t_8{font-size:8px;color: $onSurfaceCss;}
.t_10{font-size:10px;color: $onSurfaceCss;}
.t_12{font-size:12px;color: $onSurfaceCss;}
.t_11{font-size:11px;color: $onSurfaceCss;}
.t_14{font-size:14px;color: $onSurfaceCss;}
.t_16{font-size:16px;color: $onSurfaceCss;}
.t_18{font-size:18px;color: $onSurfaceCss;}
.t_20{font-size:20px;color: $onSurfaceCss;}
.t_22{font-size:22px;color: $onSurfaceCss;}
.t_25{font-size:25px;color: $onSurfaceCss;}
.t_34{font-size:34px;color: $onSurfaceCss;}
.c0{color:#000000;}
.c1{color:$primaryColorCss;}
.c2{color:#00CD00;}
.c3{color:$primaryColorCss;}
.cg{color:#00CD00}
.cf{color:#ffffff;}
.ca{color:#aaaaaa;}
.cd{color:$onSurfaceCss;}
.cc{color:#9E9C9C;}
.ce{color:#ff0000;}
.ex{color:#15ac78;}
.ee{color:#eeeeee;}
.red{color:red;}
.green{color:green;}
.f5{color:#5F5F5F;}
.ed{color:#f57489}
.nae{color:#2606cd}
.backg{background:#ffffff;}
.bahs{background:#eeeeee;}
.pink{background:#ffeeee;}
.b{font-weight:bold;}
._b{font-weight:normal;}
.hei{font-family:'黑体';}
.shou{font-family:'宋体';}
.arial{font-family:'arial';}
.ps{color:#aaaaaa;font-family:'arial';font-weight:normal;font-size:12px;}
.pes{font-weight:normal;font-size:12px;}
.m_xt{border-bottom:1px solid #eee;margin-top:20px;margin-bottom:20px;}
.m_xtx{border-bottom:1px solid #eee;margin-top:10px;margin-bottom:10px;}
.m_xtxs{border-bottom:1px solid #eee;}
.g_xy{border-bottom:1px solid #cccccc;margin-bottom:13px;}
/*************************常用布局****************/
.ht16{line-height:16px;}
.ht18{line-height:18px;}
.ht{line-height:20px;}
.hb{line-height:22px;}
.h24{line-height:24px;}
.h26{line-height:26px;}
.h38{line-height:38px;}
.t_center{text-align:center;}
.t_right{text-align:right;}
.t_left{text-align:left;}
.f_left{float:left;}
.f_right{float:right;}
.f_rights{width:288px;background:$cardHeadColorCss; float:right; padding-left:420px; height:40px; line-height:40px;}
.clear{clear:both;height:0px;overflow:hidden;}
.clear_l{clear:left;height:0px;overflow:hidden;}
.clear_r{clear:right;height:0px;overflow:hidden;}
.p10{padding:10px;}
.p_top5{padding-top:5px;}
.p5{padding:5px;}
.p20{padding-left:20px;}
.p_right{padding-right:30px;}
.p_right20{padding-right:20px;}
.p_right5{padding-right:5px;}
.m10{margin:10px;}
.top5{margin-top:5px;}
.top6{margin-top:6px;}
.top10{margin-top:10px}
.top15{margin-top:15px}
.top20{margin-top:20px}
.top25{margin-top:25px;}
.top30{margin-top:30px}
.top40{margin-top:40px}
.line2{line-height:200%}
.p_bottom10{padding-bottom:10px;}
.m_bottom30{margin-bottom:30px;}
.m_bottom15{margin-bottom:15px;}
.m_bottom10{margin-bottom:10px;}
.m_bottom20{margin-bottom:20px;}
.m_bottom25{margin-bottom:25px;}
.m_bottom30{margin-bottom:30px;}
.m_bottom35{margin-bottom:35px;}
.m_bottom40{margin-bottom:40px;}
.m_bottom5{margin-bottom:5px;}
.m_left5{margin-left:5px;}
.m_left20{margin-left:20px;}
.m_left{margin-right:10px;}
.m_left10{margin-left:10px;}
.m_left15{margin-left:15px;}
.m_right20{margin-right:20px;}
.m_left25{margin-left:25px;}
.m_left30{margin-left:30px;}
.m_left35{margin-left:35px;}
.m_left40{margin-left:40px;}
.m_left45{margin-left:45px;}
.m_left50{margin-left:50px;}
.m_left55{margin-left:55px;}
.m_left60{margin-left:60px;}
.m_right{margin-left:28px;}
.m_right28{margin-right:28px;}
.m_right10{margin-left:10px;}
.m_right3{margin-right:3px;}
.m_right5{margin-right:5px;}
.m_right15{margin-right:15px;}
.m_right25{margin-right:25px;}
.m_right2{margin-right:20px;}
/*页宽*/ 
.w_auto{width:auto;}
.w10{width:10px;}  .w12{width:12px;}  .w14{width:14px;} .w16{width:16px;}  .w18{width:18px;}  .w20{width:20px;}  .w22{width:22px;}  .w24{width:24px;}  
.w28{width:28px;}  .w30{width:30px;}  .w32{width:32px;} .w36{width:36px;}  .w38{width:38px;}  .w40{width:40px;}  .w42{width:42px;}  .w44{width:44px;}
.w46{width:46px;}  .w48{width:48px;}  .w50{width:50px;} .w52{width:52px;}  .w54{width:54px;}  .w56{width:56px;}  .w58{width:58px;}  .w60{width:60px;}
.w62{width:62px;} .w63{width:63px;} .w64{width:64px;} .w65{width:65px;} .w66{width:66px;} .w68{width:68px;}  .w70{width:70px;}  .w72{width:72px;}  .w74{width:74px;}  .w76{width:76px;}
.w78{width:78px;}  .w80{width:80px;}  .w82{width:82px;} .w84{width:84px;}  .w86{width:86px;}  .w88{width:88px;}  .w90{width:90px;}  .w92{width:92px;}
.w94{width:94px;}  .w96{width:96px;}  .w97{width:97px;}.w98{width:98px;}
.w100{width:100px;}  .w108{width:108px;} .w110{width:110px;}  .w112{width:112px;}  .w115{width:115px;} .w120{width:120px;}  .w125{width:125px;} .w128{width:128px;} .w130{width:130px;} .w135{width:135px;}  .w140{width:140px;}  
.w143{width:143px;}.w150{width:150px;}  .w151{width:151px;}  .w152{width:152px;} .w153{width:153px;} .w160{width:160px;}.w165{width:160px;}.w168{width:168px;}
.w170{width:170px;}  .w171{width:171px;}   .w173{width:173px;}  .w175{width:175px;}  .w177{width:177px;} .w179{width:179px;}  .w180{width:180px;}  .w182{width:182px;}  .w190{width:190px;}  .w192{width:192px;}  .w200{width:200px;}  .w210{width:210px;}  .w220{width:220px;}  .w225{width:225px;}  .w230{width:230px;}   .w232{width:232px;}
.w240{width:240px;}  .w250{width:250px;}  .w260{width:260px;}  .w270{width:270px;}  .w280{width:280px;}  .w290{width:290px;}  .w300{width:300px;}
.w307{width:307px;}   .w310{width:310px;}  .w320{width:320px;}  .w330{width:330px;}  .w340{width:340px;}  .w350{width:350px;}  .w360{width:360px;}  .w370{width:370px;}
.w380{width:380px;}  .w380{width:380px;}  .w387{width:387px;}  .w390{width:390px;}  .w400{width:400px;}  .w410{width:410px;}  .w420{width:420px;}  .w430{width:430px;}
.w440{width:440px;}  .w450{width:450px;}  .w460{width:460px;}  .w470{width:470px;}  .w480{width:480px;}  .w490{width:490px;}  .w500{width:500px;}
.w510{width:510px;}  .w520{width:520px;}  .w530{width:530px;}  .w540{width:540px;}  .w550{width:550px;}  .w560{width:560px;}  .w570{width:570px;}
.w580{width:580px;}  .w590{width:590px;}  .w600{width:600px;}  .w610{width:610px;}  .w620{width:620px;}  .w630{width:630px;}  .w640{width:640px;}
.w650{width:550px;}  .w660{width:660px;}  .w670{width:670px;}  .w680{width:680px;}  .w690{width:690px;}  .w700{width:700px;}  .w710{width:710px;}
.w720{width:720px;}  .w730{width:730px;}  .w740{width:740px;}  .w750{width:750px;}  .w760{width:760px;}  .w770{width:770px;}  .w780{width:780px;}
.w790{width:790px;}  .w800{width:800px;}  .w810{width:810px;}  .w820{width:820px;}  .w830{width:830px;}  .w840{width:840px;}  .w850{width:850px;}
.w860{width:860px;}  .w870{width:870px;}  .w880{width:880px;}  .w890{width:890px;}  .w900{width:900px;}  .w910{width:910px;}  .w920{width:920px;}
.w930{width:930px;}  .w940{width:940px;}  .w950{width:950px;}  .w960{width:960px;}  .w970{width:970px;}  .w980{width:980px;}  .w990{width:990px;}
.wp80{width:80%;} .wp85{width:85%;} .wp90{width:90%;} .wp95{width:95%;} .wp100{width:100%;} 
/*页高*/
.h_auto{height:auto;}
.h1{height:1px;} .h2{height:2px;} .h3{height:3px;} .h4{height:4px;} .h5{height:5px;} .h6{height:6px;}.h7{height:7px;}  .h8{height:8px;} .h9{height:9px;}
.h10{height:10px;} .h12{height:12px;} .h14{height:14px;} .h16{height:16px;}  .h18{height:18px;}  .h20{height:20px;}  .h22{height:22px;}  .h24{height:24px;}
.h26{height:26px;} .h28{height:28px;} .h30{height:30px;} .h32{height:32px;}  .h34{height:34px;} .h35{height:35px;}  .h36{height:36px;}  .h38{height:38px;}  .h40{height:40px;}
.h42{height:42px;} .h44{height:44px;} .h46{height:46px;} .h48{height:48px;}  .h50{height:50px;}  .h52{height:52px;}  .h54{height:54px;}  .h56{height:56px;}
.h58{height:58px;} .h60{height:60px;} .h62{height:62px;} .h64{height:64px;}  .h66{height:66px;}  .h68{height:68px;}  .h70{height:70px;}  .h72{height:72px;}
.h74{height:74px;} .h76{height:76px;} .h78{height:78px;} .h80{height:80px;}  .h82{height:82px;}  .h84{height:84px;}  .h86{height:86px;}  .h88{height:88px;}
.h90{height:90px;} .h92{height:92px;} .h94{height:94px;} .h96{height:96px;}  .h98{height:98px;}
.h100{height:100px;} .h110{height:110px;} .h120{height:120px;} .h130{height:130px;} .h140{height:140px;} .h150{height:150px;} .h160{height:160px;} 
.h170{height:170px;} .h180{height:180px;} .h190{height:190px;} .h200{height:200px;} .h210{height:210px;} .h220{height:220px;} .h230{height:230px;} 
.h240{height:240px;} .h250{height:250px;} .h260{height:260px;} .h270{height:270px;} .h280{height:280px;} .h290{height:290px;} .h300{height:300px;} 
.h310{height:310px;} .h320{height:320px;} .h330{height:330px;} .h340{height:340px;} .h350{height:350px;} .h360{height:360px;} .h370{height:370px;} 
.h380{height:380px;} .h390{height:390px;} .h400{height:400px;} .h410{height:410px;} .h420{height:420px;} .h430{height:430px;} .h440{height:440px;}
.h450{height:450px;} .h460{height:460px;} .h470{height:470px;} .h480{height:480px;} .h490{height:490px;} .h500{height:500px;} .h510{height:510px;}

/*行高*/
.lh_8{line-height:8px;} .lh_10{line-height:10px;} 
.lh_12{line-height:12px;}  .lh_13{line-height:13px;}  .lh_14{line-height:14px;}  .lh_15{line-height:15px;}  .lh_16{line-height:16px;}  .lh_17{line-height:17px;}
.lh_18{line-height:18px;}  .lh_19{line-height:19px;}  .lh_20{line-height:20px;}  .lh_21{line-height:21px;}  .lh_22{line-height:22px;}  .lh_23{line-height:23px;}
.lh_24{line-height:24px;}  .lh_25{line-height:25px;}  .lh_26{line-height:26px;}  .lh_27{line-height:27px;}  .lh_28{line-height:28px;}  .lh_29{line-height:29px;}
.lh_30{line-height:30px;}  .lh_31{line-height:31px;}  .lh_32{line-height:32px;}  .lh_33{line-height:33px;}  .lh_34{line-height:34px;}  .lh_35{line-height:35px;}
.lh_36{line-height:36px;}  .lh_37{line-height:37px;}  .lh_38{line-height:38px;}  .lh_39{line-height:39px;}  .lh_40{line-height:40px;}  .lh_41{line-height:41px;}
.lh_42{line-height:42px;}  .lh_43{line-height:43px;}  .lh_44{line-height:44px;}  .lh_45{line-height:45px;}  .lh_46{line-height:46px;}  .lh_47{line-height:47px;}
.lh_48{line-height:48px;}  .lh_49{line-height:49px;}  .lh_50{line-height:50px;}  .lh_51{line-height:51px;}  .lh_52{line-height:52px;}  .lh_53{line-height:53px;}
.lh_54{line-height:54px;}  .lh_55{line-height:55px;}  .lh_56{line-height:56px;}  .lh_57{line-height:57px;}  .lh_58{line-height:58px;}  .lh_59{line-height:59px;}
.lh_60{line-height:60px;}  .lh_61{line-height:61px;}  .lh_62{line-height:62px;}  .lh_63{line-height:63px;}  .lh_64{line-height:64px;}  .lh_65{line-height:65px;}
.lh_66{line-height:66px;}  .lh_67{line-height:67px;}  .lh_68{line-height:68px;}  .lh_69{line-height:69px;}  .lh_70{line-height:70px;}  .lh_71{line-height:71px;}
.lh_72{line-height:72px;}  .lh_73{line-height:73px;}  .lh_74{line-height:74px;}  .lh_75{line-height:75px;}  .lh_76{line-height:76px;}  .lh_77{line-height:77px;}
.lh_78{line-height:78px;}  .lh_79{line-height:79px;}  .lh_80{line-height:80px;}  .lh_81{line-height:81px;}  .lh_82{line-height:82px;}  .lh_83{line-height:83px;}
.lh_84{line-height:84px;}  .lh_85{line-height:85px;}  .lh_86{line-height:86px;}  .lh_87{line-height:87px;}  .lh_88{line-height:88px;}  .lh_89{line-height:89px;}
.lh_90{line-height:90px;}  .lh_91{line-height:91px;}  .lh_92{line-height:92px;}  .lh_93{line-height:93px;}  .lh_94{line-height:94px;}  .lh_95{line-height:95px;}
.lh_96{line-height:96px;}  .lh_97{line-height:97px;}  .lh_98{line-height:98px;}  .lh_99{line-height:99px;}  .lh_100{line-height:100px;}

/*边距*/
.mg1{margin:1px;} .mg2{margin:3px;} .mg3{margin:3px;} .mg4{margin:4px;} .mg5{margin:5px;} .mg6{margin:6px;} .mg7{margin:7px;} .mg8{margin:8px;} .mg9{margin:9px;} .mg10{margin:10px;}
.mt1{margin-top:1px;}  .mt2{margin-top:2px;}  .mt3{margin-top:3px;}  .mt4{margin-top:4px;}  .mt5{margin-top:5px;}  .mt6{margin-top:6px;}  .mt7{margin-top:7px;}
.mt8{margin-top:8px;}  .mt9{margin-top:9px;}  .mt10{margin-top:10px;}  .mt20{margin-top:20px;}  .mt30{margin-top:30px;}  .mt40{margin-top:40px;}  .mt50{margin-top:50px;}
.mr1{margin-right:1px;}  .mr2{margin-right:2px;}  .mr3{margin-right:3px;}  .mr4{margin-right:4px;}  .mr5{margin-right:5px;}  .mr6{margin-right:6px;}  
.mr7{margin-right:7px;}  .mr8{margin-right:8px;}  .mr9{margin-right:9px;}  .mr10{margin-right:10px;}
.ml1{margin-left:1px;}  .ml2{margin-left:2px;}  .ml3{margin-left:3px;}  .ml4{margin-left:4px;}  .ml5{margin-left:5px;}  .ml6{margin-left:6px;}  .ml7{margin-left:7px;}
.ml8{margin-left:8px;}  .ml9{margin-left:9px;}  .ml10{margin-left:10px;}  .ml15{margin-left:15px;}
.mb1{margin-bottom:1px;}  .mb2{margin-bottom:2px;}  .mb3{margin-bottom:3px;}  .mb4{margin-bottom:4px;}  .mb5{margin-bottom:5px;}  .mb6{margin-bottom:6px;}
.mb7{margin-bottom:7px;}  .mb8{margin-bottom:8px;}  .mb9{margin-bottom:9px;}  .mb10{margin-bottom:10px;}  .mb20{margin-bottom:20px;}  .mb30{margin-bottom:30px;}

.pd0{padding:0px;}  .pd1{padding:1px;} .pd2{padding:3px;} .pd3{padding:3px;} .pd4{padding:4px;} .pd5{padding:5px;} .pd6{padding:6px;} .pd7{padding:7px;} .pd8{padding:8px;} .pd9{padding:9px;} .pd10{padding:10px;}
.pt1{padding-top:1px;}  .pt2{padding-top:2px;}  .pt3{padding-top:3px;}  .pt4{padding-top:4px;}  .pt5{padding-top:5px;}  .pt6{padding-top:6px;}  .pt7{padding-top:7px;}
.pt8{padding-top:8px;}  .pt9{padding-top:9px;}  .pt10{padding-top:10px;}  .pt12{padding-top:12px;} .pt15{padding-top:15px;}  .pt20{padding-top:20px;} .pt30{padding-top:30px;} .pt40{padding-top:40px;} .pt50{padding-top:50px;}
.pr1{padding-right:1px;}  .pr2{padding-right:2px;}  .pr3{padding-right:3px;}  .pr4{padding-right:4px;}  .pr5{padding-right:5px;}  .pr6{padding-right:6px;}
.pr7{padding-right:7px;}  .pr8{padding-right:8px;}  .pr9{padding-right:9px;}  .pr10{padding-right:10px;} .pr20{padding-right:20px;} .pr30{padding-right:30px;} .pr40{padding-right:40px;}  .pr50{padding-right:50px;}  .pr60{padding-right:60px;}
.pl7{padding-left:7px;}  .pl8{padding-left:8px;}  .pl9{padding-left:9px;}  .pl10{padding-left:10px;} .pl1{padding-left:1px;}  .pl2{padding-left:2px;}  
.pl3{padding-left:3px;}  .pl4{padding-left:4px;}  .pl5{padding-left:5px;}  .pl6{padding-left:6px;} .pl18{padding-left:18px;} .pl20{padding-left:20px;} .pl30{padding-left:30px;} .pl40{padding-left:40px;} .pl50{padding-left:50px;} .pl100{padding-left:100px;} .pl125{padding-left:125px;} .pl150{padding-left:150px;} .pl200{padding-left:200px;}
.pb1{padding-bottom:1px;}  .pb2{padding-bottom:2px;}  .pb3{padding-bottom:3px;}  .pb4{padding-bottom:4px;}  .pb5{padding-bottom:5px;}  .pb6{padding-bottom:6px;}
.pb7{padding-bottom:7px;}  .pb8{padding-bottom:8px;}  .pb9{padding-bottom:9px;}  .pb10{padding-bottom:10px;}
 
/*************************常规文字连接样式****************/
a:link{text-decoration:none;color:$primaryColorCss;font-size:14px;}
a:visited{text-decoration:none;color:$primaryColorCss;font-size:14px;}
a:hover{text-decoration:underline;color:$primaryColorCss;font-size:14px;}
#leader a:link{display:block;float:left;padding:0px 10px;margin-right:10px;text-decoration:none;color:#ffffff;font-size:14px;line-height:22px;}
#leader a:visited{display:block;float:left;padding:0px 10px;margin-right:10px;text-decoration:none;color:#ffffff;font-size:14px;line-height:22px;}
#leader a:hover{display:block;float:left;padding:0px 10px;margin-right:10px;text-decoration:none;color:#ffffff;font-size:14px;background:$primaryColorCss;line-height:22px;}
#leaders a:link{text-decoration:none;color:#ffffff;}
#leaders a:visited{text-decoration:none;color:#ffffff;}
#leaders a:hover{text-decoration:underline;color:#ffffff;}
.a8 a:link{text-decoration:none;color:$primaryColorCss;font-size:8px;}
.a8 a:visited{text-decoration:none;color:$primaryColorCss;font-size:8px;}
.a8 a:hover{text-decoration:underline;color:$primaryColorCss;font-size:8px;}
.a10 a:link{text-decoration:none;color:$primaryColorCss;font-size:10px;}
.a10 a:visited{text-decoration:none;color:$primaryColorCss;font-size:10px;}
.a10 a:hover{text-decoration:underline;color:$primaryColorCss;font-size:10px;}
.a12 a:link{text-decoration:none;color:$primaryColorCss;font-size:12px;}
.a12 a:visited{text-decoration:none;color:$primaryColorCss;font-size:12px;}
.a12 a:hover{text-decoration:underline;color:$primaryColorCss;font-size:12px;}
.a16 a:link{text-decoration:none;color:$primaryColorCss;font-size:16px;}
.a16 a:visited{text-decoration:none;color:$primaryColorCss;font-size:16px;}
.a16 a:hover{text-decoration:underline;color:$primaryColorCss;font-size:16px;}
.ml12 a:link{text-decoration:none;color:#D05558;font-size:12px;}
.ml12 a:visited{text-decoration:none;color:#D05558;font-size:12px;}
.ml12 a:hover{text-decoration:underline;color:#D05558;font-size:12px;}
.a12_bjf a:link{text-decoration:none;color:#fff;font-size:12px;font-weight:bold;}
.a12_bjf a:visited{text-decoration:none;color:#fff;font-size:12px;font-weight:bold;}
.a12_bjf a:hover{text-decoration:underline;color:#fff;font-size:12px;font-weight:bold;}
.a12_f a:link{text-decoration:none;color:#fff;font-size:12px;}
.a12_f a:visited{text-decoration:none;color:#fff;font-size:12px;}
.a12_f a:hover{text-decoration:underline;color:#fff;font-size:12px;}
.ac a:link{text-decoration:underline;color:$primaryColorCss;font-size:12px;}
.ac a:visited{text-decoration:underline;color:$primaryColorCss;font-size:12px;}
.ac a:hover{text-decoration:underline;color:$primaryColorCss;font-size:12px;}
.c14 a:link{text-decoration:none;color:#990000;font-size:14px;font-weight:bold;}
.c14 a:visited{text-decoration:none;color:#990000;font-size:14px;font-weight:bold;}
.c14 a:hover{text-decoration:underline;color:#990000;font-size:14px;font-weight:bold;}
.ac14 a:link{text-decoration:none;color:$primaryColorCss;font-size:14px;}
.ac14 a:visited{text-decoration:none;color:$primaryColorCss;font-size:14px;}
.ac14 a:hover{text-decoration:underline;color:$primaryColorCss;font-size:14px;}
.c12 a:link{text-decoration:none;color:#990000;font-size:12px;}
.c12 a:visited{text-decoration:none;color:#990000;font-size:12px;}
.c12 a:hover{text-decoration:underline;color:#990000;font-size:12px;font-weight:bold;}
.ac12 a:link{text-decoration:underline;color:$primaryColorCss;font-size:12px;}
.ac12 a:visited{text-decoration:underline;color:$primaryColorCss;font-size:12px;}
.ac12 a:hover{text-decoration:underline;color:$primaryColorCss;font-size:12px;}
.a13 a:link{text-decoration:none;color:$primaryColorCss;font-size:12px;}
.a13 a:visited{text-decoration:none;color:$primaryColorCss;font-size:12px;}
.a13 a:hover{text-decoration:none;color:$primaryColorCss;font-size:12px;}
.af12 a:link{text-decoration:none;color:$primaryColorCss;font-size:14px;}
.af12 a:visited{text-decoration:none;color:$primaryColorCss;font-size:14px;}
.af12 a:hover{text-decoration:underline;color:$primaryColorCss;font-size:14px;}
.abg a:link{text-decoration:none;color:$primaryColorCss;background:$cardHeadColorCss;padding:0px 5px;font-size:12px;}
.abg a:visited{text-decoration:none;color:$primaryColorCss;background:$cardHeadColorCss;padding:0px 5px;font-size:12px;}
.abg a:hover{text-decoration:none;color:#ffffff;background:$primaryColorCss;padding:0px 5px;font-size:12px;}
.a25 a:link{text-decoration:none;color:$primaryColorCss;font-size:25px;}
.a25 a:visited{text-decoration:none;color:$primaryColorCss;font-size:25px;}
.a25 a:hover{text-decoration:underline;color:$primaryColorCss;font-size:25px;}
.a18 a:link{text-decoration:none;color:#f81111;font-size:18px;}
.a18 a:visited{text-decoration:underline;color:#f81111;font-size:18px;}
.a18 a:hover{text-decoration:underline;color:#f81111;font-size:18px;}
.fontSt {
    font-family: "宋体";
}
/*背景色*/
.bg_9F9{background-color:#9F9F9F;}/*淡灰*/ .bg_e1f{background-color:#e1f9fd;}/*浅蓝*/ .bg_fff{background-color:#fff;}/*白*/    .bg_ccc{background-color:#ccc;}/*灰*/ 
.bg_f0f{background-color:#f0f0f0;}/*浅灰*/ .bg_006{background-color:#006699;}/*蓝*/   .bg_ff0{background-color:#ff0000;}/*红*/ .bg_cc0{background-color:#cc0000;}/*深红*/ 
.bg_f9f{background-color:$cardHeadColorCss;}/*浅灰*/.bg_f009{background-color:#009900;}/*绿*/.bg_f06{background-color:#006600;}/*深绿*/

/*字体颜色库*/
.FONT_COLOR_1{color:#000000;}  .FONT_COLOR_2{color:#FFFFFF;}  .FONT_COLOR_3{color:#24AA09;}  .FONT_COLOR_4{color:#008B00;}  .FONT_COLOR_5{color:#FFD700;}  .FONT_COLOR_6{color:#F99C00;}  .FONT_COLOR_7{color:#FF5C00;}  .FONT_COLOR_8{color:#CC0000;}  .FONT_COLOR_9{color:#636DEA;}  .FONT_COLOR_10{color:#2A6D92;}  .FONT_COLOR_11{color:#8E388E;}  .FONT_COLOR_12{color:#CCCCCC;}  .FONT_COLOR_13{color:#ffffee;} .FONT_COLOR_14{color:#f1fedd;}
/*背景颜色库*/
.BG_COLOR_1{background-color:#ffffff;} .BG_COLOR_2{background-color:$cardHeadColorCss;} .BG_COLOR_3{background-color:#f0f0f0;} .BG_COLOR_4{background-color:#EDEEEE;} .BG_COLOR_5{background-color:#cccccc;} .BG_COLOR_6{background-color:#F2F8FE;} .BG_COLOR_7{background-color:#E4EFF9;} .BG_COLOR_8{background-color:#DDEDFB;} .BG_COLOR_9{background-color:#9FDFE9;} .BG_COLOR_10{background-color:#639CC4;} .BG_COLOR_11{background-color:#2E8BDF;} .BG_COLOR_12{background-color:#636DEA;} .BG_COLOR_13{background-color:#2A6D92;} .BG_COLOR_14{background-color:#ffffee;} .BG_COLOR_15{background-color:#FFF8DC;} .BG_COLOR_16{background-color:#FFE1FF;} .BG_COLOR_17{background-color:#FAF0DD;} .BG_COLOR_18{background-color:#EEF48C;} .BG_COLOR_19{background-color:#F1DA25;} .BG_COLOR_20{background-color:#EFBE23;} .BG_COLOR_21{background-color:#F99C00;} .BG_COLOR_22{background-color:#FF5C00;} .BG_COLOR_23{background-color:#EE6A50;} .BG_COLOR_24{background-color:#EE2C2C;}   .BG_COLOR_25{background-color:#cc0000;} .BG_COLOR_26{background-color:#B5DE27;} .BG_COLOR_27{background-color:#66CD00;}  .BG_COLOR_28{background-color:#24AA09;} .BG_COLOR_29{background-color:#548B54;}

/************页宽**********/
.main{width:800px;margin:0px auto;}
.leftbar{width:210px;float:left;}
.rightbar{width:590px;float:right;}
.logo_rectangle_div{width:300px;}
.logo{padding:5px;border-bottom:8px solid $primaryColorCss;background:$darkCardColorCss}
.login{background:$cardHeadColorCss;padding:15px;border-bottom:1px solid $cardHeadColorCss}
.input_login{width:140px;border:1px solid $cardHeadColorCss;height:18px;margin-top:10px;}
.bur_login{width:118px;border:1px solid $cardHeadColorCss;height:18px;margin-top:10px;margin-left:15px;margin-right:5px;}
.checkbox_login{margin-top:10px;}
.bt_login{background:$darkCardColorCss;color:#ffffff;line-height:16px;margin-top:10px;padding:0px 10px;border:1px solid #560D0F;border-top-color:#CD6366;border-left-color:#CD6366}
.bar_login{background:$darkCardColorCss;color:#ffffff;line-height:16px;margin-top:10px;padding:0px 5px;border:1px solid #560D0F;border-top-color:#CD6366;border-left-color:#CD6366}
#leader{background:$darkCardColorCss;width:570px;padding:6px 0px 6px;}
#leaders{background:$darkCardColorCss;width:570px;padding:8px 0px 6px!important;padding:8px 0 0 0;}
#leaders li{padding-right:7px !important;padding-right:2px;}
.ctbody{border:1px solid #B8B8B8;width:588px;}
.btop{background:$cardHeadColorCss;border-top:1px solid #ffffff;border-bottom:1px solid #cccccc;height:46px;}
.photo{height:100%;width:150px;margin-left:20px;position:relative;top:-20px;border:1px solid $cardHeadColorCss;padding:5px;background:#ffffff;}
.photo2{float:right;width:150px;margin-right:20px;display:inline;position:relative;top:-20px;border:1px solid $cardHeadColorCss;padding:5px;background:#ffffff;}
.ct{float:right;width:375px;padding:20px 10px;font-size:14px;line-height:34px;}
.ct2{padding:20px;font-size:14px;line-height:34px;}
.ct3{float:left;width:355px;padding:20px 20px;font-size:14px;line-height:34px;}
.sname{font-size:25px;font-weight:bold;color:$primaryColorCss}
.sname_se{font-size:25px;font-weight:bold;float:left;width:300px;color:$primaryColorCss}
.ctindent{margin-left:30px;line-height:20px;}
.schname{font-size:16px;color:$primaryColorCss;font-weight:bold}
.byyear{color:$cardHeadColorCss;font-size:30px;font-family:Arial;float:right;margin:10px;}
.gradua{color:$cardHeadColorCss;font-size:30px;font-family:Arial;margin:10px 0px;}
.gradua a:link{text-decoration:none;color:$primaryColorCss;font-size:30px;font-family:Arial;}
.gradua a:visited{text-decoration:none;color:$primaryColorCss;font-size:30px;font-family:Arial;}
.gradua a:hover{text-decoration:underline;color:$primaryColorCss;font-size:30px;font-family:Arial;}
.byyear_phot{color:$cardHeadColorCss;font-size:30px;font-family:Arial;float:right;margin-right:24px;position:relative;top:-10px;}
.foot{border-top:2px solid #eeeeee;padding:8px 0px;color:#aaaaaa;}
.absent{background:#ffeeee;cursor:pointer}
.yearlist{background:transparent; border-bottom: 1px solid $primaryColorCss;}
.yearlist_top{background:transparent; border-top: 1px solid $primaryColorCss;}
.studentgpa{background:$cardHeadColorCss repeat-x bottom; padding:0px 0px 0px 10px;}
.monlist{border:1px solid #BB5557;border-top:0px;background:#EC8688 url('/static/images/bgmonth.gif') repeat-x top;height:28px;}
.actyear{font-size:12px;font-weight:bold;color:$primaryColorCss;float:right;border:1px solid #BB5557;border-bottom:1px solid #F2ABAD;padding:0px 10px;line-height:24px;margin-right:5px;background:#F2A7A8 url('/static/images/bgyear.gif') repeat-x top;}
.actyear_mor{font-size:12px;font-weight:bold;color:$primaryColorCss;float:right;border:1px solid #BB5557;border-bottom:1px solid #F2ABAD;padding:0px 10px;line-height:24px;margin-right:5px;background:#F2A7A8 url('/static/images/bgyear_mor.gif') repeat-x top;}
.actyear_eve{font-size:12px;font-weight:bold;color:$primaryColorCss;float:right;border:1px solid #BB5557;border-bottom:1px solid #F2ABAD;padding:0px 10px;line-height:24px;margin-right:5px;background:#F2A7A8 url('/static/images/bgyear_eve.gif') repeat-x top;}
.ste_eve{font-size:12px;font-weight:bold;color:$primaryColorCss;float:left;border:1px solid #BB5557;border-bottom:1px solid #F2ABAD;padding:0px 10px;line-height:24px;margin-right:5px;background:#F2A7A8 url('/static/images/bgyear_eve.gif') repeat-x top;}
.nomyear{float:right;border:1px solid #cccccc;border-bottom:0px;padding:0px 10px;line-height:24px;margin-right:5px;background:#eeeeee url('/static/images/bgnomyear.gif') repeat-x top;}
.studentgpas{float:left;border:1px solid #cccccc;border-bottom:1px solid #cccccc;padding:0px 10px;line-height:24px;margin-right:5px;background:#eeeeee url('/static/images/bgnomyear.gif') repeat-x top;}
.nommonth{float:left;width:45px;text-align:center;line-height:28px;}
.actmonth{float:left;width:45px;text-align:center;line-height:28px;background:url('/static/images/bgactmonth.gif') no-repeat 8px 4px;color:$primaryColorCss;font-size:12px;font-weight:bold}
.totalcq{border:1px solid #EC8688;color:#000000;font-size:12px;padding:5px 10px;line-height:25px;}
.nomalday{background:#f0fff0;}
#info{border:2px solid #EC8688;background:#ffffff;padding:10px;width:100px;position:absolute;display:none}
.oktd{font-size:12px;margin-right:10px;background:#f0fff0;float:left;width:80px;text-align:center;border:1px solid #eeeeee}
.errtd{font-size:12px;margin-right:10px;background:#ffeeee;float:left;width:80px;text-align:center;border:1px solid #eeeeee}
.todtd{font-size:12px;margin-right:10px;background:url('/static/images/today.gif') no-repeat 0px 2px;float:left;width:80px;text-align:center;border:1px solid #eeeeee}
.cqlkk{height:20px;padding:1px;border:1px solid $cardHeadColorCss;float:left;width:400px;}
.cqltt{height:20px;background:#ff8888;filter:alpha(opacity=20,finishopacity=100,style=1);width:1px;}
.cqlvalue{line-height:24px;font-size:14px;color:$primaryColorCss;font-weight:bold;margin-left:5px;}
.jt1{float:left;display:inline;margin-left:318px;cursor:pointer}
.jt2{float:left;display:inline;margin-left:31px;cursor:pointer}
.jt3{float:left;display:inline;margin-left:11px;cursor:pointer}
.jt4{float:left;display:inline;margin-left:11px;cursor:pointer}
.cloudlogo{margin:100px 30px 30px;text-align:left;}
.cloudinfo{text-align:left;background:$darkCardColorCss;padding:20px 20px 20px 50px;color:#ffffff;font-size:25px;font-weight:bold;border-bottom:8px solid #FF9696}
.cloudinfo2{text-align:left;padding:20px 20px 20px 50px;color:#000000;font-size:14px;line-height:25px;}
.cloudct{margin-left:25px;margin-top:20px;float:left;border-left:1px solid #FF9696;}
.cloudtt{background:#FF9696;color:#ffffff;line-height:25px;text-align:center;width:100px;}
.cloudct ul{margin-top:10px}
.cloudct li{border-bottom:1px solid #FF9696;float:left;margin-right:10px;}
.tlisttop{margin-top:30px;border-bottom:1px solid #eeeeee;color:#aaaaaa;font-size:16px;}
.tlisttop_x{margin-top:15px;border-bottom:1px solid #eeeeee;color:#aaaaaa;font-size:16px;}
.tesev_fe{margin-top:40px;border-bottom:1px solid #eeeeee;color:#aaaaaa;font-size:16px;}
.wydgw_ae{border-bottom:1px solid #eeeeee;color:#aaaaaa;font-size:16px;}
.subjectname{color:$primaryColorCss;font-size:25px;}
.subjectlo{color:$primaryColorCss;font-size:16px;}
.bacofyv{border-bottom:1px solid $primaryColorCss;}

/******gao*****/
.ly_puts{width:300px;height:50px;}
.ly_put{width:100%;height:50px}
.text_inp{width:138px;;height:50px;margin-top:10px;}
.input_wz{font-size:12px;color:#808080;}
.f_righ_dl{font-size:12px;padding-left:300px;}
.abc{width:300px;float:right;}
.f_righ_a{font-size:12px;font-family:'arial';padding-left:350px;padding-top:50px;}
.f_righ_mak{font-size:12px;font-family:'arial';float:right;padding-top:20px;padding-bottom:5px;}
.ag_fon{font-size:14px;}
.ag_bj a:link{text-decoration:none;color:$primaryColorCss;background:$cardHeadColorCss;padding:0px 2px;}
.ag_bj a:visited{text-decoration:none;color:$primaryColorCss;background:$cardHeadColorCss;padding:0px 2px;}
.ag_bj a:hover{text-decoration:none;color:#ffffff;background:$primaryColorCss;padding:0px 2px;}

.mark_bj a:link{text-decoration:none;color:$primaryColorCss;background:$cardHeadColorCss;padding:5px 7px;}
.mark_bj a:visited{text-decoration:none;color:#ffffff;background:$primaryColorCss;padding:5px 7px;}
.mark_bj a:hover{text-decoration:none;color:$primaryColorCss;background:$cardHeadColorCss;padding:5px 7px;}

.nwov a:link{text-decoration:none;color:$primaryColorCss;background:$cardHeadColorCss;padding:2px 2px 1px 2px;}
.nwov a:visited{text-decoration:none;color:#ffffff;background:$primaryColorCss;padding:2px 2px 1px 2px;}
.nwov a:hover{text-decoration:none;color:$primaryColorCss;background:$cardHeadColorCss;padding:2px 2px 1px 2px;}

.photo1{float:left;margin-left:20px;display:inline;position:relative;top:-20px;padding:3px;border:1px solid $cardHeadColorCss;background:#ffffff;}
.photosz{float:left;padding:3px;border:1px solid $primaryColorCss;background:$primaryColorCssTransparent;margin-right:10px;}
.cta{float:left;width:500px;font-size:14px;line-height:34px;padding-left:20px;margin-top:20px;color:$onSurfaceCss}
.ctin_bj{margin-top:20px;background:$cardHeadColorCss;border-top:1px solid #D8DFEA;border-bottom:1px solid #D8DFEA;padding:28px 0px 18px 28px;height:100%;}
.ctin_ea{margin-top:5px;background:$cardHeadColorCss;border-top:1px solid #D8DFEA;border-bottom:1px solid #D8DFEA;padding:25px 0px 20px 25px;height:100%;}
.ctin_smoe{padding-bottom:25px;margin-top:10px;background:$cardHeadColorCss;border-top:1px solid #D8DFEA;border-bottom:1px solid #D8DFEA;height:100%;}
.ctin_one{margin-top:5px;padding:0px 0px 18px 21px;height:100%;}
.pgraph img{border:1px solid #D8DFEA;background:#ffffff;padding:5px;width:100px;}
.fgrdae img{float:left;border:1px solid #D8DFEA;background:#ffffff;padding:5px;margin-bottom:18px;margin-right:28px;width:100px;}
.byyear1{color:$cardHeadColorCss;font-size:30px;font-family:Arial;float:right;margin:10px 10px 10px 30px;}
.sname a:link{text-decoration:none;color:$primaryColorCss;font-size:14px;font-size:25px;font-weight:bold;}
.sname a:visited{text-decoration:none;color:$primaryColorCss;font-size:14px;font-size:25px;font-weight:bold;}
.sname a:hover{text-decoration:underline;color:$primaryColorCss;font-size:14px;font-size:25px;font-weight:bold;}
.cdf{width:80px;margin-left:110px;position:relative;top:-10px;}
.reverse{text-align:right;padding-top:3px;padding-right:5px;}
.reverse a:link{text-decoration:none;color:$primaryColorCss;font-size:12px;}
.reverse a:visited{text-decoration:none;color:$primaryColorCss;font-size:12px;}
.reverse a:hover{text-decoration:underline;color:$primaryColorCss;font-size:12px;}
.mapht{float:left;}
.jqtext{float:left;width:365px;line-height:22px;font-size:12px;margin-top:10px;border-right:1px solid #CDCBCB;padding-right:20px;}
.jqtext_hong{float:left;width:365px;height:1100px;line-height:22px;font-size:12px;margin-top:10px;border-right:1px solid #CDCBCB;padding-right:20px;}
.jqtext_wz img{padding:3px;border:1px solid #CDCBCB;margin-left:3px;}
.tlisttop1{padding-top:30px;border-bottom:1px solid #eeeeee;margin-bottom:5px;}
.subjectname1{color:$primaryColorCss;font-size:18px;}
.xylb{line-height:30px;}
.fone_r{color:$primaryColorCss;font-size:16px;}
.photo2{float:left;width:50px;margin-left:5px;top:10px;padding:3px;border:1px solid $cardHeadColorCss;background:#ffffff;}
.dges{float:right;width:150px;margin-left:10px;font-size:12px;margin-top:10px;}
.sname1{font-size:25px;font-weight:bold;float:left;margin-right:5px;}
.britain{float:left;padding-top:6px !important;padding-top:4px;}
.f_bec{margin-top:10px;width:50px;}
.f_bea{line-height:22px;}
.britas img{float:left;padding:2px;border:1px solid #CDCBCB;margin-bottom:10px;width:110px;overflow:hidden;}
.britt img{float:left;padding:2px;border:1px solid #CDCBCB;margin-bottom:10px;}
.grad_uat img{padding:2px;border:1px solid #CDCBCB;}
.brittew img{float:left;width:50px;height:50px;padding:2px;border:1px solid #CDCBCB;margin-bottom:10px;}
.britas_pres img{float:right;padding:2px;margin-bottom:5px;}
.subject{font-size:25px;float:left;color:#000000;}
.bdaef{color:$primaryColorCss;font-weight:bold;height:30px;background:#E6E2E2;}
.mxb{border:1px solid #ffffff;}
.sdfhiw{font-family:'arial';color:#666666;height:24px;text-align:center;border:1px solid #F4F2F2}
.tomda{text-align:right;padding-top:3px;}
.sdfhiw1{font-family:'arial';color:#666666;height:24px;text-align:center;background:$cardHeadColorCss;border:1px solid #F4F2F2;}
.schname a:link{text-decoration:none;font-size:16px;color:$primaryColorCss;font-weight:bold}
.schname a:visited{text-decoration:none;font-size:16px;color:$primaryColorCss;font-weight:bold}
.schname a:hover{text-decoration:none;font-size:16px;color:$primaryColorCss;font-weight:bold}
.jqtext_wz{font-size:12px;height:22px;}
.csaef{color:#eeeeee;}
.dgese{float:left;width:117px;margin-left:10px;font-size:12px;line-height:22px;color:#868383;margin-top:10px;}
.dgesex{float:left;width:180px;font-size:12px;line-height:22px;margin-top:10px}
.dgesep{float:left;width:158px;font-size:12px;line-height:22px;color:#868383;margin-top:30px;}
.dgesep_xt{float:left;width:158px;font-size:12px;line-height:22px;color:#868383;margin-top:30px;border-left:1px solid #CDCBCB;}
.jqtext_wz{display:block ;}
.sp_wz{width:245px;float:left;padding-top:5px;}
.video{float:left;background:#F9F6F6;width:109px;line-height:20px;padding:3px;margin-right:10px;padding-bottom:0;border:1px solid #E1DDDD;margin-bottom:15px;}
.afeeo{float:left;background:#F9F6F6;width:109px;line-height:20px;padding:3px;padding-bottom:0;border:1px solid #E1DDDD;margin-bottom:15px;}
.video_mira{float:left;background:#F9F6F6;width:109px;line-height:20px;padding:3px;margin-right:1px !important;margin-right:3px;padding-bottom:0;border:1px solid #E1DDDD;margin-bottom:15px;}
.video1{float:left;background:#F8F3F3;width:109px;line-height:20px;padding:3px;margin-right:12px;padding-bottom:0;border:1px solid #E1DDDD;margin-bottom:15px;}
.image img{float:right;padding:3px;border:1px solid #CDCBCB;margin-left:3px;}
.jqtext_vis{float:left;width:400px;line-height:22px;font-size:12px;margin-top:10px;border-right:1px solid #CDCBCB;padding-right:20px;}
.jqtext_viz{float:left;width:400px;line-height:22px;font-size:12px;margin-top:30px;border-right:1px solid #CDCBCB;padding-right:10px;padding-left:10px;}
.jqtext_xt{float:left;width:400px;line-height:22px;font-size:12px;margin-top:30px;padding-left:10px;margin-right:10px !important;margin-right:5px;}
.jqtext_qde{width:567px;line-height:22px;font-size:12px;margin-top:30px;padding-right:10px;padding-left:10px;}
.jqtext_x{float:left;width:340px;line-height:22px;font-size:12px;margin-top:10px;padding-right:20px;}
.jqtext_sul{float:left;width:547px;line-height:22px;font-size:12px;margin-top:10px;}
.jqtext_prae{height:780px;float:left;width:400px;line-height:22px;font-size:12px;margin-top:10px;border-right:1px solid #CDCBCB;padding-right:20px;}
.visabe{display:block;padding-top:4px;text-align:center;}
.vid_bj{height:100%;background:#eeeeee url('/static/images/lect_pic03.jpg') repeat-x top;margin-bottom:10px;}
.afhafe_xz{background:#eeeeee url('/static/images/lect_pic08.jpg') repeat-x top;margin-bottom:10px;}
.video_bt{float:left;background:#D9D2D2;width:109px;line-height:20px;padding:3px;margin-right:12px;padding-bottom:0;border:1px solid #C1BFBF;margin-bottom:10px;margin-top:20px;}
.plisttop{padding-top:20px;border-bottom:1px solid #eeeeee;margin-bottom:5px;}
.vip_pic{float:left;display:block;background: url('/static/images/gif-0550.gif') repeat-x bottom;width:19px;height:18px;}
.maraes{margin-bottom:20px;width:396px;height:234px;}
.top_mwf{display:block;text-align:right;padding-right:10px;padding-top:15px;}
.top_pres{display:block;float:left;padding-top:20px;padding-left:22px;}
.top_gs{display:block;float:left;padding-top:20px;padding-left:205px;}
.passpt{margin-top:20px;}
.passpt_mp{float:left;width:305px;height:187px;margin-right:30px;margin-bottom:20px;}
.hr1{background: #DBDBDB;height: 1px;overflow:hidden;}
.login_hy{padding-left:25px;padding-top:15px;background:$cardHeadColorCss;line-height:12px;}
.input_logins{width:60px;border:1px solid $cardHeadColorCss;height:18px;margin-bottom:5px !important;margin-bottom:0px ;position:relative;top:-2px;}
.input_logint{width:140px;border:1px solid $cardHeadColorCss;height:18px;margin-top:10px;}
.pass_sou{float:left;width:85px;height:53px;margin-right:5px;margin-bottom:5px;}
.login_in{position:relative;top:-5px;}
.login_inz{margin-left:3px;float:left}
.login_ins{position:relative;top:-5px;float:left;width:145px;}
.log_fae{padding:7px;line-height:16px;border:1px dashed #B8B8B8;margin-right:20px;background:#ffffff;}
.log_faz{padding:7px;line-height:16px;border:1px dashed #B8B8B8;margin-right:20px;background:#ffffff;margin-top:8px;margin-bottom:10px;}
.pop_bj{background:#F9FED7;height:auto;}
.pop_su{float:left; background:#F9FED7; width:97%;}
.pop_sus{background:#F9FED7; width:100%; text-align:center;;}
.pop_gb{display:block;padding-top:10px;text-align:right;padding-right:10px;padding-bottom:10px;background:#F9FED7;line-height:25px; width:728px;}
.popse{padding-left:15px;padding-top:10px;background:#F9FED7;}
.login_pa{padding-top:12px;}
.part_ta{padding-bottom:15px;margin-left:5px;letter-spacing:1px;}
.part_at{margin-top:8px;margin-left:5px;}
.taeacd{text-align:left;border:1px solid #CCC7C7;}
.part_teb{line-height:16px;padding:8px 0;border:1px solid #CCC7C7;}
.part_tet{line-height:16px;padding:2px 0;border:1px solid #CCC7C7;text-align:left;padding-left:20px;}
.part_tex{line-height:16px;padding:2px 0;border:1px solid #CCC7C7;text-align:left;padding-left:20px;background:#F4F2F2;}
.part_tef{line-height:16px;padding:8px 0;border:1px solid #CCC7C7;background:#FCE4E4;}
.xdeb{border:1px solid #CCC7C7;margin-bottom:30px;}
.caefy_ae{padding-bottom:5px;margin-left:8px;}
.caefy_aes{padding-bottom:5px;margin-top:40px;margin-left:8px;}
.part_top{margin-bottom:5px;background:$cardHeadColorCss;line-height:25px;padding-left:5px;}
.part_right{margin-bottom:12px;background:$cardHeadColorCss;line-height:25px;padding-left:5px;margin-top:33px}
.part_uae{margin-bottom:10px;background:$primaryColorCssTransparent;line-height:25px;padding-left:5px;border-top:1px solid $primaryColorCss}
.part_cae{margin-top:40px;margin-bottom:10px;background:$primaryColorCssTransparent;line-height:25px;padding-left:5px;border-top:1px solid $primaryColorCss;}
.part_ct{margin-top:40px;margin-bottom:12px;background:$primaryColorCssTransparent;line-height:25px;padding-left:5px;border-top:1px solid $primaryColorCss;}
.part_lef{width:380px;float:left;margin-left:3px;}
.part_ce{margin:3px 0 20px 20px;}
.part_cs{margin:3px 0 0px 20px;}
.part_fon{display:block;margin-top:10px;}
.part_img{float:left;margin-top:3px;width:60px;}
.grad_miat{float:left;margin-top:3px;width:118px;line-height:18px;margin-bottom:22px;}
.grad_uae{float:left;margin-top:3px;line-height:18px;}
.part_bj a:link{text-decoration:none;color:#ffffff;background:#515151;font-size:12px;}
.part_bj a:visited{text-decoration:none;color:#ffffff;background:#515151;font-size:12px;}
.part_bj a:hover{text-decoration:none;color:#ffffff;background:$primaryColorCss;font-size:12px;}
.part_coun{float:left;width:128px;padding-left:5px;margin-bottom:10px;margin-top:7px;}
.part_t{display:block;float:left;margin-left:5px;position:relative;top:-1px;}
.part_b{display:block;float:left;}
.badedade{margin-bottom:8px;}
.login_awn{margin-top:5px;margin-bottom:5px;}
.pop_bmit{height:23px;}
.todays{background:url('/static/images/today.gif') no-repeat 17px 0px;text-align:center;line-height:18px;margin-bottom:1px;}
.gaeme{margin-top:25px;}
.input_pr{border:1px solid $cardHeadColorCss;height:16px;margin-top:10px;width:20px;}
.praeame{margin-top:9px;float:left;}
.cadess{margin-top:30px;}
.afea{float:left}
.cdae{line-height:5px;display:block;margin-bottom:30px;}
.caefd{width:78px;float:left}
.daefad{margin-left:2px;}
.sma_top{width:200px;float:left;display:block;padding:3px 0 0 3px;}
.log_l{margin-top:330px;width:220px;float:left;padding-top:4px;padding-bottom:4px;border-top:1px solid #C9C9C9;border-bottom:1px solid #C9C9C9;}
.log_left{height:155px;background:#064B8E;}
.log_b{margin-top:330px;float:left}
.log_r{margin-top:330px;float:left;height:155px;padding-top:4px;padding-bottom:4px;border-top:1px solid #EAEAEA;border-bottom:1px solid #EAEAEA;}
.log_right{float:left;height:155px;background:#1890CC;}
.log_bj{float:left}
.log_bj_a{float:left;background:#1890CC;padding-top:16px;}
.log_dae{margin-top:20px;float:left;padding-right:15px;}
.log_aeq{margin-top:20px;float:left;margin-right:2px;}
.log_pic_am{width:28px;float:left;padding-top:6px;}
.log_fon{color:#ffffff;}
.log_inpt{width:70px;height:12px;}
.log_ines{width:50px;height:12px;}
.log_cae{float:left;padding-top:35px;}
.log_cat{float:left;padding-top:38px;margin-left:5px;}
.ceadea{background:url('/static/images/admin_bj.gif');height:700px;padding-top:50px;text-align:center}
.presde_se{width:364px;background:#FBFBFB;padding-top:3px;border:1px solid #E8E7E7;}
.presde_tion{background:$cardHeadColorCss;padding-top:3px;border-top:1px solid #cccccc;line-height:20px;margin-top:5px;}
.presde_qea{float:left;width:100px;}
.fefae{width:98px;float:left;margin-left:1px;}
.cqlks{height:20px;padding:1px;border:1px solid $cardHeadColorCss;float:left;width:360px;}
.jq1{float:left;display:inline;margin-left:265px;cursor:pointer}
.jq2{float:left;display:inline;margin-left:31px;cursor:pointer}
.jq3{float:left;display:inline;margin-left:11px;cursor:pointer}
.jq4{float:left;display:inline;margin-left:11px;cursor:pointer}
.dent_de{width:363px;background:#FBFBFB;padding-top:3px;padding-bottom:3px;border:1px solid #E8E7E7;}
.den_cor1{background:#6DD46D}
.den_cor2{background:#7CE57C}
.den_cor3{background:#9BF39B}
.den_cor4{background:#4CC84C}
.dent_wid{float:left;margin-left:24px;width:52px;line-height:28px;text-align:center}
.dent_wids{float:left;margin-left:3px !important;margin-left:2px;width:52px;line-height:28px;background:#BFFABF;text-align:center}
.caefaye{display:block;line-height:22px;border-top:2px solid $primaryColorCss;border-bottom:2px solid $primaryColorCss;width:140px;float:left;color:#8A8585;margin-top:8px;margin-bottom:1px;margin-right:10px;padding:10px 0px;}
.taeq_qb{margin-top:10px;}
.sgbrt_img{float:left;margin-right:10px;width:60px;margin-left:6px;}
.sgbrtgea{float:left;margin-right:20px;width:60px;}
.presde_cea{margin-left:5px;}
.pafegb{float:left;width:52px;margin-left:25px;}
.pafegb_a{float:left;width:52px;margin-left:3px !important;margin-left:2px;}
.sec1 {display:block;float:left;padding:0px 8px;margin-right:2px;text-decoration:none;color:#ffffff;font-size:14px;line-height:22px;}
.sec2 {display:block;float:left;padding:0px 8px;margin-right:2px;text-decoration:none;color:#ffffff;font-size:14px;line-height:20px;background:$primaryColorCss;}
.paegeafe{display:block;margin-top:10px;}
.feafe{width:266px;float:right;}
.cdeae{padding-top:10px;margin-left:5px;width:360px;}
.peafde{margin-left:5px;display:block;margin-bottom:10px;}
.gadfe{width:300px;position:relative;top:-6px;}
.maetea{width:140px;}
.caegba{width:350px;}
.maegeq{border-bottom:1px solid #E2E6ED;height:28px;}
.maegeb{border-bottom:1px solid #E2E6ED;height:28px;margin-top:6px;}
.maeg_pic{position:relative;top:3px;margin-right:5px;}
.mae a:link{text-decoration:none;color:$primaryColorCss;font-size:12px;}
.mae a:visited{text-decoration:none;color:$primaryColorCss;font-size:12px;}
.mae a:hover{text-decoration:none;color:#ffffff;background:$primaryColorCss;font-size:12px;}
.may a:link{text-decoration:none;color:#1DA01D;font-size:12px;}
.may a:visited{text-decoration:none;color:#1DA01D;font-size:12px;}
.may a:hover{text-decoration:none;color:#ffffff;background:#1DA01D;font-size:12px;}
.mat a:link{text-decoration:none;color:#5D5959;font-size:12px;}
.mat a:visited{text-decoration:none;color:#5D5959;font-size:12px;}
.mat a:hover{text-decoration:none;color:#ffffff;background:#5D5959;font-size:12px;}
.photo_xz{width:105px;margin-left:3px;margin-right:19px;}
.afda{border:1px solid #BB5557;border-top:0px;}
.xaefrq{padding-top:10px;margin-left:5px;width:300px;}
.efrq{margin-left:10px;}
.morn_sub{margin-left:100px;margin-bottom:10px;}
.lesson_sel{padding-top:10px;margin-left:25px;}
.bae_mor{background:#ffffff;}
.mesag{margin-left:5px;}
.gagea{float:left;margin-right:17px;line-height:20px;position:relative;left:23px;top:25px;margin-bottom:20px;width:170px;}
.ade_inp{width:70px;border:1px solid #D4D0C8}
.qagex{padding-right:24px !important;padding-right:18px;}
.qagua{padding-right:24px !important;padding-right:18px;margin-top:8px;}
.eqgua{margin-top:2px;}
.dfte_img li{float:left;list-style:none;height:170px;}
.dfte img{padding:5px;border:1px solid #D8DFEA;background:#ffffff}
.sy_tea{margin-top:10px;margin-left:15px;}
.lae_bic{padding-right:24px;}
.mae_tok{position:relative;top:-20px;padding-left:25px;}
.pho_mai{margin-bottom:20px;}
.login_sul{margin-bottom:30px;}
.text_sul{width:400px;height:100px;}
.inp_sult{position:relative;top:2px;}
.teax_sult{display:block;float:left;padding-top:3px;}
.input_con{width:140px;border:1px solid $cardHeadColorCss;height:18px;}
.xb_sult{padding-top:33px;}
.xg_sult{padding-top:20px;}
.caeq_sult{margin-bottom:65px;}
.aexb{width:100%;border-collapse:collapse;border:1px solid $cardHeadColorCss;line-height:20px;}
.searxb{width:100%;border-collapse:collapse;border:0px solid $cardHeadColorCss;line-height:20px;}
.aexbs{width:60%;border-collapse:collapse;border:1px solid $cardHeadColorCss;line-height:20px;}
.aexb th{background:#f3f3f3;padding:3px;}
.searxbj{background:#f3f3f3;padding:3px;}
.sexbj{background:#F9F8F8;padding:3px;}
.sxbj{background:#ffffff;padding:3px;}
.aqradf_bj{background:#f3f3f3;font-weight:bold;height:30px;}
.aexb td{height:26px;}
.sk{float:left;margin:4px 6px 0px 2px;line-height:12px;width:9px;overflow:hidden}
.tae_paa{padding:5px 10px;}
.tatio_top{margin-top:20px;font-size:14px;border-bottom:1px solid #FFD4D5;color:#C24C4F;}
.coiuy_bj{background:#E8F8FF}
.coiuyaq_bj{background:#D8FEEC}
.cousa_bj{background:#FFD9DA}
.afeqq_im{display:block;width:20px;line-height:0px;float:left;}
.priay_cav{float:left;width:50px;margin-left:3px !important;margin-left:2px;margin-bottom:5px;margin-top:10px;padding-left:28px;}
.priay_ae{float:left;width:50px;margin-left:29px;margin-bottom:5px;margin-top:10px;}
.uqyo_af{width:50px;height:20px;overflow:hidden;}
.deo_cso{position:relative;top:3px;}

.priay_ao{float:left;margin-left:3px !important;margin-left:2px;margin-bottom:5px;margin-top:10px;}
.priay_se{float:left;margin-right:29px;margin-bottom:5px;margin-top:10px;margin-left:3px;}
.zly_se{float:left;margin-right:28px;margin-bottom:5px;padding-top:20px;}
.xapu_mae{width:550px;margin:auto;padding:auto;white-space:nowrap;padding-left:22px;}
.zly_mae{width:520px;margin:auto;padding:auto;white-space:nowrap;margin-right:5px;position:relative;top:-10px;}
.mark_padi{position:relative;top:3px;}
.mark_py{position:relative;top:-10px;margin-bottom:10px;}
.mark_py_20{position:relative;top:-24px;}
.choosec_20{position:relative;top:-26px;}
.my_dfae{position:relative;top:-45px;margin-left:70px;}
.my_dfaecou{position:relative;top:-25px;margin-left:70px;}
.mark_inpu{background: #ffffff;border-top: 1px solid #bdbbbb;vertical-align:center;}
.maar_cav{float:left;width:50px;margin-left:5px !important;margin-left:2px;margin-bottom:5px;padding-left:15px;line-height:25px;}
.maar_ae{float:left;width:50px;margin-right:35px !important;margin-right:27px;margin-bottom:5px;line-height:25px;position:relative;left:25px;}
.head_maoi img{padding:3px;border:1px solid #CDCBCB;}
.head_maoi{width:58px;}
.choos_maoi{float:right;width:138px;}
.choos_maoi img{padding:3px;border:1px solid #CDCBCB;}
.head_aefr img{padding:3px;border:1px solid #CDCBCB;}
.head_aefr{margin-left:10px;}
.ytafeef{width:530px;line-height:25px;}
.mark_ouye{margin-top:30px;}
.mark_ouye_ks{margin-top:40px;}
.mark_tabl{width:100%;border-collapse:collapse;border:1px solid #ffffff;line-height:30px;}
.tafeyl_ay{border-right:1px solid #ffffff;border-bottom:1px solid $cardHeadColorCss; color: $onSurfaceCss;}
.adfea{width:48px;overflow:hidden;text-overflow:ellipsis; white-space:nowrap;}
.adfea_vae{width:56px;overflow:hidden;text-overflow:ellipsis; white-space:nowrap;background:#cdcbcb;}
.gayea_ki{width:500px;margin-left:25px;}
.toayht{width:530px;}
.capyht{width:470px;margin-left:18px;margin-bottom:5px;}
.dsiyse{background:#F7F6F7;width:500px;}
.fafea{width:500px;background:url('/static/images/uyc_bj.gif') no-repeat;}
.hr1{border-bottom:1px dotted #bbb;}
.uaf_eq img{padding:0px;margin:0px;width:9px;height:9px;}
.uaf_eq{padding-top:5px;}
.fegse{background:#F7F6F7;width:360px;}
.fegses{background:#eeeeee;width:360px;}
.pafe{width:50px;}
.faefva{width:530px;}
.dapyeve{width:400px;}
.epane{width:530px;background:#eee;line-height:22px;margin-bottom:10px;padding-left:10px;}
.dfaf{margin-left:5px;}
.gea_ae{float:left;width:50px;margin-right:30px !important;margin-right:22px;margin-bottom:5px;line-height:25px;position:relative;left:20px;}
.mayc_pave{position:relative;top:275px;padding-left:490px !important;padding-left:483px;}
.cours_paiu{position:relative;top:230px;padding-left:490px !important;padding-left:483px;}
.fadkae{position:relative;top:-10px;}
.ceadf{width:595px;}
.tes_mge{line-height:20px;width:58px;}
.tes_mge img{padding:3px;background:#cdcbcb}
.tes_wit{float:left;width:50px;margin-right:23px !important;margin-right:15px;margin-bottom:5px;line-height:25px;position:relative;left:25px;}
.loadbg{position:absolute;background:#ff8800;color:#ffffff;padding:2px 10px;line-height:20px;display:none;}
.loadbg_1{position:absolute;background:#ffffff;color:#ff8800;padding:5px;line-height:20px;display:none;}
.middle_div_style{position:absolute; top:50%; left:50%;background:$cardHeadColorCss;border:1px solid #ff8800;padding:10px;line-height:20px;display:none;}
.faeve_se{float:left;width:545px;line-height:22px;font-size:12px;margin-top:10px;}
.bain{font-size:12px;color:#666666;padding-top:21px;padding-left:78px;padding-bottom:20px;}
.bain_wid{width:210px;float:left}
.uave{color:#180404;font-size:18px;margin-top:15px;margin-left:30px;}
.uave_b{margin-left:62px;}
.uave_c{margin-left:45px;}
.bai_botom{margin-bottom:16px;}
.allexam{margin-top:15px;margin-bottom:10px;background:#eeeeee;padding-left:10px;padding-top:0px !important;padding-top:5px;padding-bottom:0px !important;padding-bottom:5px;}
.allexam_cor{margin-bottom:10px;background:#eeeeee;padding-left:10px;padding-left:10px;padding-top:0px !important;padding-top:5px;padding-bottom:0px !important;padding-bottom:5px;}
.ghome_bauv{background:#eeeeee;margin-bottom:10px;padding-left:30px;padding-top:5px;padding-bottom:5px;}
.td_padin{padding-top:2px;padding-bottom:2px;}
.cadv_im{width:77px;}
.sel_lf{width:55px;}
.all_paduv{padding-top:3px;;padding-bottom:3px;}
.hodcj_pic{padding-top:8px;padding-right:4px;}
.badedad{margin-bottom:8px;}
.decav_a{margin-top:5px;background:#ff3322;padding-bottom:1px;margin-right:5px;padding-left:3px;padding-top:3px;padding-right:2px;}
.decav_b{margin-top:5px;background:#8d8dfe;padding-bottom:3px;padding-left:3px;padding-top:2px;padding-right:2px;}
.decav_c{margin-top:5px;background:#FED7D7;padding-left:3px;padding-top:4px;margin-right:5px;padding-bottom:2px;padding-right:2px;}
.decav_d{margin-top:5px;background:#d5e706;padding-bottom:1px;padding-left:3px;margin-left:5px;padding-top:2px;padding-right:2px;}
.decav_e{margin-top:5px;background:#20e737;padding-bottom:2px;padding-left:3px;margin-left:5px;padding-top:2px;padding-right:2px;}
.meair_lef{float:left;width:700px;}
.meair_lefs{float:left;width:700px; padding:0px 20px; 0px 20px;}
.med_fiayv{margin:3px 0px 5px 5px;color:#696767;float:left;}
.melis_fi{margin:0px 0px 5px 5px;color:#696767;float:left;}
.med_ficef{margin:3px 0px 5px 20px;color:#696767;float:left;}
.mlis_mz{margin:0px 0px 0px 5px;color:#696767;float:left;width:50px;}
.mlis_mzs{margin:0px 0px 0px 5px;color:#696767;float:left;width:150px;}
.mlis_iyv{margin:0px 0px 0px 5px;color:#696767;float:left;width:300px;}
.mlis_iyvs{margin:0px 0px 0px 5px;color:#696767;float:left;width:200px;}
.mlis_tei{margin:0px 0px 0px 5px;color:#696767;float:left;width:120px;}
.mlis_teis{margin:0px 0px 0px 5px;color:#696767;float:right;width:200px;}
.mlis_im{margin:4px 0px 0px 20px;color:#696767;float:left;width:50px;}
.mlis_sc{margin:4px 0px 0px 0px;color:#696767;float:right;width:30px;}
.med_fjay{margin:4px 0px 5px 20px;color:#696767;float:left;}
.mlis_sc a:link{text-decoration:none;background:url('/static/images/sc_pic1.jpg') repeat-x;}
.mlis_sc a:visited{text-decoration:none;background:url('/static/images/sc_pic1.jpg') repeat-x}
.mlis_sc a:hover{text-decoration:none;background:url('/static/images/sc_pic.jpg') repeat-x;}
.mlis_se{margin:4px 0px 0px 0px;color:#696767;float:right;width:30px;}
.mlis_se a:link{text-decoration:none;background:url('/static/images/icon_edit.gif') repeat-x;}
.mlis_se a:visited{text-decoration:none;background:url('/static/images/icon_edit.gif') repeat-x}
.mlis_se a:hover{text-decoration:none;background:url('/static/images/icon_edit.gif') repeat-x;}
.mlis_iyv{width:580px;height:35px;}
.mlis_iyv ul{height:35px;}
.mlis_iyv ul li{float:left;height:35px;}


.mliy_du{margin-right:3px;float:right;}
.ofice_du{margin-left:5px;float:left;margin-bottom:5px;}
.meair_zy{padding-left:10px;}
.tdbj{background:#FDCACA;}
.tdbjkk{background:#FCFDCA;}
.tdbjqj{background:#CAFDDC;}
.kq_table{margin-top:30xp;}
.coyate{width:56px;float:left;}
.coyates{width:76px;float:left;}
.coyate_ra{float:left;margin-bottom:5px;}
.coymain{margin-bottom:5px;}
.mess_left{float:left;width:560px;}
.mess_right{float:right;width:140px;background:#eeeeee;}
.mes_main{width:700px;}
.aivye_ou{padding-left:5px;position:relative;top:7px;}
.aivye_riv{padding-left:5px;padding-bottom:5px;border:1px solid #aaaaaa;margin-left:5px;margin-right:5px;margin-bottom:5px;}
.mes_pic{padding-left:10px;background:url('/static/images/gif-0865.gif') no-repeat 0px 7px;}
.mes_pin{padding-left:10px;}
.mes_selec{width:65px;}
.mes_selec_120{width:120px;}
.inpay_mad{width:430px;}
#mytjgg{position:relative;top:-25px;}
.vidy_abe{width:70px;float:left;}
.vidy_cie{width:50px;float:right;}
.rywft_dev{margin-bottom:5px;background:$cardHeadColorCss;line-height:25px;padding-left:5px;width:153px;}
.wyly_oic{float:left;padding-top:5px;padding-left:20px;}
.coauwid{padding-left:20px;}
.coauwid_wh{width:698px;}
.neam_wih{width:75px;margin-top:3px;}
.paiyve_eve{height:97px;}
.sn_div{background:$primaryColorCss;color:#ffffff;padding:3px;line-height:18px;text-align:center;margin:3px;display:inline;}
.wiveye{float:left;background:$primaryColorCss;color:#ffffff;padding:0 3px;line-height:14px;text-align:center;margin-right:3px;}
.wiveye_span{background-color:$primaryColorCss;color:#ffffff;padding:3px;line-height:14px;text-align:center;margin-right:3px;}
.wiveye_span2{background-color:$primaryColorCss;color:#ffffff;padding:3px;line-height:14px;text-align:center;margin:1px;display:inline-block;}
.taeiyv_bj{background:none; height:34px;color:#555;line-height: 18px;}
.taeiyv_bj1{background:none; height:34px;color:#555;line-height: 18px;}
.taeiyv_bj_11per{background:none; height:34px;color:#555;line-height: 18px;}
.taeiyv_bj .week,.taeiyv_bj1 .week,.taeiyv_bj_11per .week{padding-left:30px;font-weight: bold;}
.taeiyv_bj .lesson,.taeiyv_bj1 .lesson,.taeiyv_bj_11per .lesson{font-weight: bold;}
.taepafy{position:relative;top:7px;}
.taepevs{position:relative;top:60px;left:28px;}
.teachertb{width:100%;font-size:12px;border-collapse:collapse;}
.teacher_nem{float:left;padding-top:11px;margin-right:3px;}
.teaherevsev{padding:5px 0px 0px 5px;}
.teaherev{padding:5px 0px;}
/*课表*/
.teachertb tr td div{text-align: center;}
.normal_td_t30{background-color:$surfaceColorCss; color: $onSurfaceCss !important;}
.normal_td_t30 div{margin-top:-35px;}
.normal_td, td{background-color: transparent!important;vertical-align: bottom; color: $onSurfaceCss !important;}
textarea {background-color: $darkCardColorCss;}
.breaktime_td{height: 0px;border:1px;}
.lunchtime_td{background-color:#fae3d5;}
.pastoral_td{background-color:#c5e0b4;}
.normal_td div,.lunchtime_td div,.breaktime_td div,.pastoral_td div,.normal_td_t30 div{text-align:center;}
td.vertical-top{vertical-align: top}
td.vertical-top div{text-align:center;}
#div_1310{background-color: #fae3d5;height: 15px;}
.normal_td_t30{background-color:#fff;}
.normal_td_t30 div{margin-top:-35px;}
.l-or-p{background-color: #fff2cc;}
div.isntw,div.istw{min-height:32px;position:relative;}
div.isntw{background-color:#ddd;}
div.isntw span,div.isntw span a{color:#aaaaaa !important;}
div.istw .ws-div, div.isntw .ws-div{position:absolute;display:inline;right:2px;bottom:2px;}
.ws-div {z-index:1;font-weight:bold;background-color: rgba(255,255,255,0.3);box-shadow: 0px 0px 8px rgba(0, 0, 0, 0.5);box-sizing: border-box;}
div.istw .ws-div{color:$primaryColorCss;}
div.isntw .ws-div{color:#aaa;}
#M1,#Tu1,#W1,#Th1,#F1{min-height:20px;background-image:url('/static/images/pic/period/p1.png'); background-repeat:no-repeat;background-position: bottom left;}
#M2,#Tu2,#W2,#Th2,#F2{min-height:20px;background-image:url('/static/images/pic/period/p2.png'); background-repeat:no-repeat;background-position: bottom left;}
#M3,#Tu3,#W3,#Th3,#F3{min-height:20px;background-image:url('/static/images/pic/period/p3.png'); background-repeat:no-repeat;background-position: bottom left;}
#M4,#Tu4,#W4,#Th4,#F4{min-height:20px;background-image:url('/static/images/pic/period/p4.png'); background-repeat:no-repeat;background-position: bottom left;}
#M5,#Tu5,#W5,#Th5,#F5{min-height:20px;background-image:url('/static/images/pic/period/p5.png'); background-repeat:no-repeat;background-position: bottom left;}
#M6,#Tu6,#W6,#Th6,#F6{min-height:20px;background-image:url('/static/images/pic/period/p6.png'); background-repeat:no-repeat;background-position: bottom left;}
#M7,#Tu7,#W7,#Th7,#F7{min-height:20px;background-image:url('/static/images/pic/period/p7.png'); background-repeat:no-repeat;background-position: bottom left;}
#M8,#Tu8,#W8,#Th8,#F8{min-height:20px;background-image:url('/static/images/pic/period/p8.png'); background-repeat:no-repeat;background-position: bottom left;}
#M9,#Tu9,#W9,#Th9,#F9{min-height:20px;background-image:url('/static/images/pic/period/p9.png'); background-repeat:no-repeat;background-position: bottom left;}
#M10,#Tu10,#W10,#Th10,#F10{min-height:20px;background-image:url('/static/images/pic/period/p10.png'); background-repeat:no-repeat;background-position: bottom left;}
#M11,#Tu11,#W11,#Th11,#F11{min-height:20px;background-image:url('/static/images/pic/period/p11.png'); background-repeat:no-repeat;background-position: bottom left;}
#M12,#Tu12,#W12,#Th12,#F12{min-height:20px;background-image:url('/static/images/pic/period/p12.png'); background-repeat:no-repeat;background-position: bottom left;}
#M13,#Tu13,#W13,#Th13,#F13{min-height:20px;background-image:url('/static/images/pic/period/p13.png'); background-repeat:no-repeat;background-position: bottom left;}
#M14,#Tu14,#W14,#Th14,#F14{min-height:20px;background-image:url('/static/images/pic/period/p14.png'); background-repeat:no-repeat;background-position: bottom left;}
/*课表结束*/
.hodviay{background:url('/static/images/hodcj_pic.gif') no-repeat 0px 12px;padding-left:13px;}
.neamnow{margin-top:3px;}
.nowvey_wvy{float:left;width:100px;height:85px;}
.choos_viy{margin-left:75px;position:relative;top:-10px;}
.chovev_siy{position:relative;top:-5px;}
.choosyve_wod{margin-right:5px;padding-top:10px;}
.choos_coa{margin-left:62px;}
.choos_ucaeve{margin-left:62px;}
.kajyve{display:block;padding:7px 2px 5px 15px;background:$primaryColorCss;float:left;line-height:18px;height:20px !important;height:18px;color:#ffffff;margin-right:20px;margin-bottom:10px;}
.chjyve{display:block;padding:7px 15px 5px 15px;background:#2606cd;float:left;line-height:18px;height:20px !important;height:18px;color:#ffffff;margin-right:20px;margin-bottom:10px;}
.chjyhs{display:block;padding:7px 15px 5px 15px;background:$primaryColorCss;float:left;line-height:18px;height:20px !important;height:18px;color:#ffffff;margin-right:20px;margin-bottom:10px;}
.chkiayv{float:left;line-height:30px;height:30px;margin-right:20px;vertical-align:middle;}
.chkiayv_ucaeve{margin-left:62px;}
.choos_subm{padding-top:15px;}
.chois_picy{position:relative;top:-8px;}
.clas_text{margin-left:78px;margin-top:8px;}
.liayev{margin-right:5px;margin-top:-7px;}
.pop_value{margin-left:173px;margin-top:10px;}
.pos_adm{margin-left:30px; height:auto;}
.teack_pic{height:35px;overflow:hidden;border-bottom:1px solid #b8b8b8;margin-bottom:10px;margin-top:20px;}
.student_status_,.student_status_normal{color:green;}
.student_status_out{color:#cccccc;}
.student_status_graduated, .student_status_graduated1{color:#FF0033;}
.student_status_pending{color:#bc9364;}
.student_status_xiuxue{color:yellow;}
.student_status_inactive{color:#666666;}
.tinfoay{background:$primaryColorCssTransparent;padding:10px 10px 0px 10px;height:auto !important;height:68px;min-height:69px;}
.tinfoayout{background:#cccccc;padding:10px 10px 0px 10px;height:68px;}
.tinfoayok,.tinfoaygraduated,.tinfoaygraduated1,.tinfoayok1{background:#FF0033;padding:10px 10px 0px 10px;height:68px;}
.tinfoaygraduated2,.tinfoayok2{background:#5F9EA0;padding:10px 10px 0px 10px;height:68px;}
.tinfoaypending{background:#bc9364;padding:10px 10px 0px 10px;height:68px;}
.tinfoayxiuxue{background:yellow;padding:10px 10px 0px 10px;height:68px;}
.tinfoayinactive{background:#666666;padding:10px 10px 0px 10px;height:68px;}
.tinfouc{background:#6d9ed6;padding:10px 10px 10px 8px !important; padding:10px 10px 0px 3px;}
.tinfotoy{padding:3px;border:1px solid $cardHeadColorCss;background:#ffffff;width:50px;}
.teac_corae{background:#d11720;padding:10px 10px 10px 10px !important; padding:10px 10px 0px 10px;}
.attenda{background:#f2db21;padding:10px 10px 10px 10px !important; padding:10px 10px 0px 10px;}
.aidyve{width:250px;}
.aidice{width:350px;}
.tiveye{float:left;background:$primaryColorCss;color:#ffffff;padding:0 3px;line-height:14px;text-align:center;margin-right:3px;}
.tveiyv{float:left;;margin-left:5px;margin-right:5px;line-height:14px;}
.engnem{padding-top:9px;padding-right:5px;padding-bottom:5px;text-align:right;}
.chgnem{padding-right:5px;}
.skauyv{background:$cardHeadColorCss;}
.skau_scw{background:$cardHeadColorCss;line-height:5px;}
.skauyv_scwk{background:$cardHeadColorCss;padding:5px 0;line-height:22px;}
.taiyve{float:left;background:#f9fed7;line-height:28px;padding:0 5px;width:695px;}
.qcaiyve{border-bottom:1px solid #bbb9b9;padding:0 5px;}
.qtaiyv{float:left;background:$primaryColorCss;color:#ffffff;line-height:20px;padding:0 2px;}
.qtcaiy{float:left;line-height:20px;width:130px;}
.atcaiy{float:right;line-height:20px;}
.scwkbjw{background:#e7e5e5;height:20px;padding-left:35px;padding-right:35px;}
.acwkbjw{height:20px;padding-left:35px;padding-right:35px;}
.ackbevwih{width:150px;float:left;}
.wkqcie{padding:0 10px;line-height:20px;}
.aivyea{width:200px;}
.faiyve{width:120px;padding-left:5px;padding-top:20px;}
.auaeve{margin-left:20px;}
.aiyeae{float:left;background:$primaryColorCss;color:#ffffff;line-height:14px;padding:0 2px;margin-right:5px;}
.caiyve{float:left;}
.aciayev{background:url('/static/images/pivyae.gif') no-repeat;}
.aivyeaev{float:left;padding-top:4px;}
.choose_left{float:left;width:520px;border-right:1px solid #b8b8b8}
.choose_right{float:right;width:180px;;}
.choose_taiy{margin-right:10px;}
.cgiveye{float:left;background:#2606cd;color:#ffffff;padding:0 3px;line-height:14px;text-align:center;margin-right:3px;}
.apasec{float:left;padding-right:10px;}
.apavec{float:left;padding-top:15px;border-bottom:3px solid #ab9bfd;width:436px;height:31px;}
.ckavec{float:left;padding-top:15px;border-bottom:3px solid #fb878a;width:436px;height:31px;}
.choos_corae{margin-left:62px;margin-top:20px;width:490px;}
.apivyae{padding-top:30px;}
.chosefin{width:680px;position:relative;top:0px;left:30px;display:block;}
.seftan{margin-top:80px;margin-bottom:50px;}
.dealinp{padding:5px;float:left;}
.dealk{background:$cardHeadColorCss;}
.coa_eiyv{float:left;;margin-left:5px;margin-right:5px;}
.sivywa{line-height:22px;width:400px;}
.aevvywa{line-height:22px;width:500px;}
.attendywa{line-height:22px;width:170px;}
.ghomenpi{float:left;margin-bottom:20px;padding:0 6px;height:120px;}
.aciuaev{margin-top:35px !important;margin-top:20px}
.acuayve{margin-top:20px;}
.chsn_cors{margin-right:10px;height:30px;}
.ofice_co{margin-bottom:5px;}
.chan_input{height:20px;}
.chang_xt{border-top:1px solid #cccccc;}
.chgau_bot{margin-bottom:17px;}
.chgau_top{margin-top:12px;}
.myatec{float:left;}
.myatec_rig{float:right;line-height:22px;}
.mytdbj{background:$cardHeadColorCss;width:688px;padding:0 10px;}
.morning{background:$cardHeadColorCss;width:688px;padding:0 10px 5px 10px;}
.uavyes{background:$cardHeadColorCss;padding:0 10px;width:380px;margin: 0 auto;}
.myatsyva{height:119px;margin-left:25px;background:url('/static/images/today_pic.gif') no-repeat;}
.vuyafev{float:right;color:#f81111;margin-top:90px;margin-right:5px;padding-left:20px;background:url('/static/images/gif-0549.gif') no-repeat 0px 7px;}
.kgpic{background:url('/static/images/kgpic.gif') no-repeat 80px 8px;}
.stuayve{background:url('/static/images/kgpic.gif') no-repeat 10px 8px;padding-left:35px;}
.qqpic{float:left;padding-left:10px;}
.qdpaiv{width:150px;}
.cdpic{float:right;padding-right:27px;}
.scwhvdt{background:#eeeeee;}
.scwiinput{border:solid 1px #d4d0c8;}
.eaiyve{float:left;padding-left:10px;}
.rihyve{float:right;padding-right:10px;}
.eaiv_iae{float:left;padding-top:2px;}
.haivyea{float:left;color:#aaaaaa;background:#d0fdcf;padding:0px 11px 15px 13px;margin:0 6px;}
.haiv_kae{float:left;color:#d00606;background:#d0fdcf;padding:0px 11px 15px 13px;margin-right:25px;}
.attend_kae{float:left;color:#d00606;background:#f2db21;padding:0px 11px 15px 13px;margin-right:25px;}
.attend_ea{float:left;color:#aaaaaa;background:#f2db21;padding:0px 11px 15px 13px;margin:0 6px;}
.studyvfont{font-size:50px;padding-top:7px;}
.kkaivye{text-align:center;}
.caouese3{width:400px;line-height:20px;margin-left:150px;}
.attpicg{width:130px;margin-left:80px;height:60px;background:url('/static/images/attend_pic.gif') no-repeat;}
.stutrpia{width:130px;margin-left:80px;height:60px;background:url('/static/images/stutrpia_pic.gif') no-repeat;}
.attenaiy{float:left;padding-top:15px;margin-bottom:8px;border-bottom:1px solid #eeeeee;line-height:24px;width:708px;}
.attefna{line-height:20px;padding-top:8px;}
.ateuamai{padding-left:25px;background:url('/static/images/gif-0468.gif') no-repeat 0px 6px;}
.ateuamcu{padding-left:25px;background:url('/static/images/gif-0469.gif') no-repeat 0px 6px;}
.trscou_a{background:#ff3322;width:48px;line-height:18px;margin-top:6px;text-align:center;color:#ffffff;padding:2px;1px;0px;2px;}
.trscou_b{background:#ffada7;width:48px;line-height:18px;margin-top:6px;text-align:center;color:#584c4e;padding:2px;1px;0px;2px;}
.trscou_c{background:#ffc1bc;width:48px;line-height:18px;margin-top:6px;text-align:center;color:#584c4e;padding:2px;1px;0px;2px;}
.trscou_d{background:#ffd6d3;width:48px;line-height:18px;margin-top:6px;text-align:center;color:#584c4e;padding:2px;1px;0px;2px;}
.trscou_e{background:#ffeae8;width:48px;line-height:18px;margin-top:6px;text-align:center;color:#584c4e;padding:2px;1px;0px;2px;}
.tcou_a{float:left;background:#ff3322;color:#ffffff;line-height:15px;padding:2px 4px;margin-right:10px;}
.tcou_b{float:left;background:#ffada7;color:#584c4e;line-height:15px;padding:2px 4px;margin-right:10px;}
.tcou_c{float:left;background:#ffc1bc;color:#584c4e;line-height:15px;padding:2px 4px;margin-right:10px;}
.tcou_d{float:left;background:#ffd6d3;color:#584c4e;line-height:15px;padding:2px 4px;margin-right:10px;}
.tcou_e{float:left;background:#ffeae8;color:#584c4e;line-height:15px;padding:2px 4px;}
.scwkay_rx{margin-top:20px;margin-left:20px;}
.wkaiyvw{float:left;padding-left:3px;padding-right:5px;line-height:17px;border:1px solid $cardHeadColorCss;}
.printae{float:left;margin-top:28px;padding-left:300px;}

.decav_rov{margin-bottom:10px;margin-top:10px;float:left;}
.decav_refy{margin-top:10px;float:right;}
.button{padding-top:1px;cursor:pointer;height:22px;}
#calendardiv{width:100px;}

#cidyve{;width:5px;height:10px;float:left;padding-top:6px;padding-left:2px;padding-right:2px;position:relative;left:-15px;top:2px;}

.selecusyve{width:70px;margin-left:300xp;position:absolute;left:580px;}
.selecusyve1{width:70px;margin-left:300xp;position:absolute;left:645px;}
.sel12 a:link{text-decoration:none;color:#000000;font-size:12px;}
.sel12 a:visited{text-decoration:none;color:#000000;font-size:12px;}
.sel12 a:hover{text-decoration:none;color:#ffffff;font-size:12px;}

.adfev{font-size:12px;font-weight:bold;color:$primaryColorCss;float:right;border:1px solid $primaryColorCss;border-bottom:1px solid #F2ABAD;padding:0px 10px;line-height:24px;margin-right:5px;background:$primaryColorCssTransparent !important;}
.evwear{float:right;border:1px solid #cccccc;border-bottom:0px;padding:0px 10px;line-height:24px;margin-right:5px;background:transparent !important;}
.evwear_1{float:right;border:1px solid #cccccc;padding:0px 10px;line-height:24px;margin-right:5px;background:$cardHeadColorCss !important;}

/*  1迟到.2旷课.3请假  4病假 5事假*/
.today2{background:url('/static/images/today1.gif') no-repeat 3px 2px;padding-left:18px;background-color:#ff3322;color:#FFFFFF;}
.today3{background:url('/static/images/gif-0164.gif') no-repeat 3px 2px;padding-left:18px;background-color:#D5FEEE;color:#126343;}
.today1{background:url('/static/images/gif-0165.gif') no-repeat 3px 2px;padding-left:18px;background-color:#FED7D7;color:#C33434;}
.today0{background-color:#FFFFFF;}
.today4{background:url('/static/images/gif-0164.gif') no-repeat 3px 2px;padding-left:18px;background-color:#d5e706;color:#FFFFFF;}
.today5{background:url('/static/images/gif-0440.gif') no-repeat 3px 2px;padding-left:18px;background-color:#8d8dfe;color:#FFFFFF;}
.today6{background:url('/static/images/gif-0440.gif') no-repeat 3px 2px;padding-left:18px;background-color:#20e737;color:#ffffff;}

/*  比例进度条 */
.faeiut{line-height:24px;background: radial-gradient(#efefef, #339999);}

/*血条*/
.xtaoyvae{float:left;border:1px solid #e5c9c9;width:90px;line-height:10px;background:#ffffff;padding:2px;margin-top:2px;}
.seeyve{background:$primaryColorCss;background: radial-gradient(#efefef, #FF0033);}
.auapyv{margin-left:4px;float:left;}
.pauvya{padding-top:25px;}

/* 通用 */
input{vertical-align:middle; margin-top:-2px; margin-bottom:1px;}
.wbrak{word-wrap:break-word;overflow:hidden;}
.newone {background-image:url('/static/images/newone3.gif');background-repeat:no-repeat;background-position:0px -4px;}
/*边线*/
.borderb{border-bottom:1px solid #CCCCCC;}
.borderr{border:1px solid #CD0000;}

/*新建div--用于显示信息*/
.infodiv{ position:absolute;font-size:9pt;width:320px;  background:#FFFFCC;color:#666666; padding:5px 10px 5px 5px; border:1px solid #F5C66B;line-height:20px;  display:none; 12001;}
.infodiv a { color:#000000; font-size:9pt;  text-decoration:none;  } 
.infodiv a:hover{font-size:10pt; border-bottom:dashed 1px #000000;}
.infodiv table{border:1px dotted #F5C66B;}
.infodiv table td{width:40px;text-align:center;}
/*switch开关*/
.testswitch {
    position: relative;
    float: left; 
    width: 45px;
    margin: 0;
    margin-top:7px;
    -webkit-user-select:none; 
    -moz-user-select:none; 
    -ms-user-select: none;
}
 
.testswitch-checkbox {
    display: none;
}
 
.testswitch-label {
    display: block; 
    overflow: hidden; 
    cursor: pointer;
    border: 1px solid #999999; 
    border-radius: 10px;
}
 
.testswitch-inner {
    display: block; 
    width: 200%; 
    margin-left: -100%;
    transition: margin 0.3s ease-in 0s;
}
 
.testswitch-inner::before, .testswitch-inner::after {
    display: block; 
    float: right; 
    width: 50%; 
    height: 15px; 
    padding: 0; 
    line-height: 15px;
    font-size: 10px; 
    color: white; 
    font-family: 
    Trebuchet, Arial, sans-serif; 
    font-weight: bold;
    box-sizing: border-box;
}
 
.testswitch-inner::after {
    content: attr(data-on);
    padding-left: 5px;
    background-color: #00e500; 
    color: #FFFFFF;
}
 
.testswitch-inner::before {
    content: attr(data-off);
    padding-right: 5px;
    background-color: #EEEEEE; 
    color: #999999;
    text-align: right;
}
 
.testswitch-switch {
    position: absolute; 
    display: block; 
    width: 10px;
    height: 10px;
    margin: 2px;
    background: #FFFFFF;
    top: 0; 
    bottom: 0;
    right: 28px;
    border: 2px solid #999999; 
    border-radius: 10px;
    transition: all 0.3s ease-in 0s;
}
 
.testswitch-checkbox:checked + .testswitch-label .testswitch-inner {
    margin-left: 0;
}
 
.testswitch-checkbox:checked + .testswitch-label .testswitch-switch {
    right: 0px; 
}
.accordion {
  width: 100%;
  /*max-width: 360px;*/
  margin: 30px auto 20px;
  background: $darkCardColorCss !important;
  -webkit-border-radius: 4px;
  -moz-border-radius: 4px;
  border-radius: 4px;
}
/* CSS Document */
.clear{clear:both;}
.tdrd{padding-left:5px; height:30px; line-height:30px; text-align:left;}
.textline{border-bottom:1px solid #cccccc; border-left:0px; border-right:0px; border-top:0px; color:#666666;}
.line{height:5px;}
.lineh1{height:1px; border-bottom:1px solid #cccccc;}
.lineh10{height:10px;}
.lineh20{height:20px;}
.lineh30{height:30px;}
.bgline{border-bottom:1px solid #cccccc;}
.left{text-align:left;}
.right{text-align:right;}
.center{text-align:center;}
.hanghao24{line-height:24px;}
.hanggao26{line-height:26px;}
.hanggao30{line-height:30px;}
.formkuang{width:660px; height:auto;}
.formkuang_l{width:220px; height:auto; float:left;}
.formkuang_l ul li{width:220px!important; width:220px; height:34px;}
.formkuang_r{width:400px;  height:auto; float:right;}
.formkuang_r ul li{width:400px!important; width:400px; height:34px; }
.h20{height:20px; line-height:20px;}
.h25{height:25px; line-height:25px;}
.h30{height:30px; line-height:30px;}
.h40{height:40px; line-height:40px;}


/*×ÖÌåÑùÊ½*/
.f_12{font-size:12px; color:#333333;}
.f_14{font-size:14px;}
.f_16{font-size:16px;}
.font12{font-size:12px; font-weight:bold; color:#333333;}
.font12red{font-size:12px; font-weight:bold; color:#cc0000;}
.f_11_weith{font-size:11px; color:#ffffff; text-decoration:none;}
.font18{font-size:18px; font-weight:bold; color:#333333;}
.font14red{font-size:14px; font-weight:bold; color:#cc0000;}
.font12fff{font-size:12px; color:#ffffff;}

/*ÎÄ±¾¿òÑùÊ½*/
.delete{width:60px; height:20px; border:1px #FFD9D9 solid; background-color:#FFF4F4; font-size:11px; text-align:center; padding:2px 4px 2px 4px;}
.logintext{border:0px; width:230px; height:25px; background:transparent; font-size:20px; font-weight:bold; color:#ffffff;}
.loginyzcode{width:60px; height:25px; background:transparent; font-size:20px; font-weight:bold; color:#ffffff; border:0px;}

/*Á´½ÓÑùÊ½*/

/*°´Å¥ÑùÊ½*/
.button_1{border:1px solid #891417; color:#ffffff; background-color:#891417; width:60px; height:24px;cursor:pointer;}
.submit_1{height:30px; width:88px; font-size:11px; font-weight:bold; color:#cc0000; text-align:right; padding:2px 6px 2px 4px; background:url(/static/images/pic/submitbg_2.jpg);cursor:pointer;}
.submit_2{border-width:0px; padding: 2px 0 0 0;font-size: 12px; color:#666666; background:url("/static/images/pic/button_bg1.gif");width:100px;height:30px;cursor:pointer;}
.submit_3big{border:1px solid #FFC6C6; padding: 5px; background:#FFFBFB; font-size: 12px; color:#666666; width:70px; height:30px;cursor:pointer;}

.divblock{border:1px solid #FFC6C6; padding: 5px;margin: 5px; background:#FFFBFB; font-size: 12px; color:#666666; height:auto;}
/*ÑÕÉ«ÑùÊ½*/
.green{background-color:green; color:#ffffff;}
.yellow{background-color:yellow; color:#333333;}
.zhongse{background-color:#663300; color:#ffffff;}
.blue{background-color:blue; color:#ffffff;}
.red{background:red; color:#ffffff;}
.red_to_green {background-image: linear-gradient(to right, red , green);color:#ffffff;}
.late{background:#000000; color:#ffffff;}
.white{background:#ffffff; color:#000000;}
.pik{background:#FFC0CB; color:#000000;}
.gray{background:#777; color:#fff;}
.fff{color:#cc0000;}
.cc0000{color:#cc0000;}
.ccc{color:#cccccc;}

/*±³¾°É«ÑùÊ½*/
.bgone{background-color:$cardHeadColorCss; width:100%;}
.bgyes{background:url('/static/images/yes20.gif') no-repeat;width:auto !important;min-width:25px;width:25px;height:auto !important;min-height:25px;height:25px;line-height:25px;font-size:14px;color:#000000;}
.bgnot{width:auto !important;min-width:25px;width:25px;height:auto !important;min-height:25px;height:25px;line-height:25px;font-size:14px;color:#000000;}
/* Awards and punishment*/
.ap_font_0{color:#24AA09;} /*Awards*/
.ap_font_1{color:#000000;} /*background-color:#cc0000;*/
/*GPAÒ³ÃæÑùÊ½*/
#gpa{width:706px; height:auto;}
#gpa ul li{font-size:12px;}
#gpawidth{width:706px; height:40px; padding:0px 0px 0px 10px; text-align:center;}
.gpatext{border:1px solid #cccccc; background-color:#ffffff; font-size:12px; font-family:arial; color:#999999; height:20px; padding:0px 0px 0px 5px;}
.gpabutton{border:1px solid #cccccc; background-color:#f0f0f0; font-size:12px; font-family:arial,"ËÎÌå"; height:27px; width:60px;}
.gpaselect{border:1px solid #cccccc; background-color:#f0f0f0; height:27px; width:60px;}
/*AttendanceÒ³ÃæÑùÊ½*/
/*Attendance_page{width:98%; height:auto;}*/

#Attendance_page{width:1080px;margin:auto;padding:auto;  height:auto;}
#search_sea{width:100%; height:50px; line-height:30px; border-top:0px; border-left:0px; border-right:0pox; border-bottom:1px solid #cccccc; background:$cardHeadColorCss;}
.search_form{float:left; width:62%;}
.attendance_button{width:50px; height:20px; border:1px solid #cccccc; background:#cc0000; color:#ffffff;}
.colork{width:38%; height:20px; line-height:20px; float:right; padding-top:3px;}
#formhead{width:98%;width:1080px;margin:auto;padding:auto;  height:40px; border:1px #cccccc solid; background:#f0f0f0;}
.formname{width:6.125%; height:40px; line-height:40px; text-align:center; font-weight:bold; float:left; border-left:1px solid #cccccc; border-right:0px; border-top:0px; border-bottom:0px;}
.formname_1{width:7%; height:40px; line-height:40px; text-align:center; font-weight:bold; float:left; border-left:1px solid #cccccc; border-right:0px; border-top:0px; border-bottom:0px;}

#formtr{width:98%; width:1080px;margin:auto;padding:auto; height:50px; line-height:40px; border-top:0px; border-right:1px #cccccc solid; border-bottom:1px #cccccc solid; border-left:1px #cccccc solid; background:#ffffff;}
.formtd{width:6.125%; height:44px; line-height:36px; padding:2px 0px 2px 0px; text-align:center; float:left; border-left:1px solid #cccccc; border-right:0px; border-top:0px; border-bottom:0px;}
.formtd_1{width:7%; height:44px; line-height:36px; padding:2px 0px 2px 0px; text-align:center; float:left; border-left:1px solid #cccccc; border-right:0px; border-top:0px; border-bottom:0px;}

.formtd_h20{width:100%; height:22px; line-height:11px; padding:2px 0px 0px 0px;text-align:center;}
.formtd_w14{width:87%; height:40px; line-height:40px; padding:0px 0px 0px 0px;text-align:center; float:left; border-left:1px solid #cccccc; border-right:0px; border-top:0px; border-bottom:0px;}
#att_load_more{width:98%;width:1080px;margin:auto;padding:auto;  height:40px; border:1px #cccccc solid;}
/*ÎÄÕÂÏÔÊ¾Ò³*/
.Active{width:100%; height:30px; line-height:30px;}
.Active_s{width:100%; line-height:40px;  border-bottom:1px solid #cccccc;}
.Active_content{line-height:26px; color:#666666;  width:98%; padding-top:10px; padding-left:10px;}
.return{width:100%;line-height:30px; color:#666666; border-bottom:1px solid #f0f0f0;}
.return ul li a{font-size:12px; color:#666666; text-decoration:none; line-height:30px; border:1px solid #CCCCCC; padding:2px 5px 2px 5px; background-color:#f0f0f0;}
.return ul li a:hover{font-size:12px; color:#cc0000; text-decoration:underline; line-height:30px; border:1px solid #CCCCCC; padding:2px 5px 2px 5px; background-color:$cardHeadColorCss;}
.pingyu{width:98%; line-height:30px; border-bottom:1px solid #f0f0f0; border-top:1px solid #f0f0f0; background-color:#FFF4F4; padding-left:10px;}
.pingyuc{padding-left:10px; padding-right:10px;}

/*ÁôÑÔ±¾ÑùÊ½*/
.msntitle{width:100%; height:auto; border:1px solid #cccccc; background-color:$cardHeadColorCss; line-height:30px;}
.msninfo{width:100%; height:auto; line-height:30px;}
.msncontent{width:97%; height:auto; border:1px solid #cccccc; padding:10px;}
.msnhf{width:100%; height:30px; text-align:right; line-height:30px;}
.msnreportadd{width:680px; height:auto;  text-align:left; background-color:#ffffff;}
.msnreportleft{width:165px; height:auto; float:left;}
.msnreportleft ul li{text-align:left; width:165px; height:30px; line-height:30px; border-bottom:1px solid #cccccc;}
.msnreportright{width:474px; height:auto; text-align:left; float:right;}
.msnreportright ul li{width:474px; height:30px; line-height:30px; text-align:left; border-bottom:1px solid #f0f0f0;}

/*group*/
#group{width:680px; height:auto; padding-top:20px;}
.groupquyus{width:150px; height:50px; line-height:25px; background:url(/static/images/pic/button1_bg.jpg) no-repeat; padding:6px 22px 10px 35px; float:left;color:#E7AFAE;}
.groupquyus li a{text-align:left;  text-decoration:none; color:#cc0000;}
.groupquyus li a:hover{text-align:left; text-decoration:underline; color:#cc0000;}
.grouptitle{width:705px; height:40px; line-height:40px; background:url(/static/images/pic/title_1.jpg) no-repeat;}
.grouptitles{width:222px; height:40px; float:left; text-align:center; color:#cc0000;padding-left:5px;}
.groupmsn{width:500px;width:600px !important; height:auto;height:auto !important;}
.groupmsn_l{width:140px;width:165px !important; height:300px; float:left; text-align:right;}
.groupmsn_r{width:360px;width:435px !important; height:300px; float:right; text-align:left;}

.addreport{width:500px;width:600px !important; height:auto;height:auto !important;}
.addreport ul{width:500px;width:600px !important;height:30px;height:auto;border-bottom:1px solid #ccc;}
.addreport li{float:left;height:30px;line-height:30px;vertical-align: middle;}
.addreport li.left_title{width:120px;text-align:right;font-weight:bold;}

#group_1{width:680px; height:auto; padding-top:20px;}
.groupquyus_1{width:200px; height:50px; line-height:25px; background:url(/static/images/pic/button1_bg.jpg) no-repeat; padding:6px 5px 10px 30px; float:left;}
.groupquyus_1 li a{text-align:left;  text-decoration:none; color:#cc0000;}
.groupquyus_1 li a:hover{text-align:left; text-decoration:underline; color:#cc0000;}

.groupquyus_2{width:120px; height:35px; line-height:25px; background-color:#E6E6E6; border:1px solid #cccccc; margin:2px;  padding:5px 5px 5px 5px; float:left;}
.groupquyus_2 li a{text-align:left;  text-decoration:none; color:#cc0000;}
.groupquyus_2 li a:hover{text-align:left; text-decoration:underline; color:#cc0000;}



.groupquyus_3{float:left; width:270px; height:auto !important; line-height:19px;padding:6px 0px 10px 15px; }
.groupquyus_3{background-image:url(/static/images/pic/button3_bg.jpg);background-repeat:no-repeat;background-position:left top; }
.groupquyus_3 ul{height:40px;line-height:19px; background-color:#E7AFAE;margin-left:25px;}
.groupquyus_3 li a{text-align:left;  text-decoration:none; color:#cc0000;}
.groupquyus_3 li a:hover{text-align:left; text-decoration:underline; color:#cc0000;}


.group_classroom{background:url(/static/images/pic/red-6.gif) no-repeat; width:80px; height:80px; line-height:80px; background-color:#E6E6E6; border:1px solid #cccccc; margin:2px;  padding:5px 5px 5px 5px; float:left;}
.group_classroom ul li a{text-align:left;  text-decoration:none; color:#cc0000;}
.group_classroom ul li a:hover{text-align:left; text-decoration:underline; color:#cc0000;}

.group_classroom_1{background:url(/static/images/pic/room_gray_50_50.gif) no-repeat; width:160px; height:50px; line-height:20px; background-color:#E6E6E6; border:1px solid #cccccc; margin:5px;  padding:2px 5px 2px 5px; float:left;}
.group_classroom_1 ul li {padding-left:10px;}
.group_classroom_1 ul li a{text-align:left;  text-decoration:none; color:#cc0000;}
.group_classroom_1 ul li a:hover{text-align:left; text-decoration:underline; color:#cc0000;}




.groupquyus_exam_room{width:300px; height:70px; line-height:25px; background-color:#E6E6E6; border:1px solid #cccccc; margin:5px;  padding:5px 0px 5px 0px; float:left;}
.groupquyus_exam_room ul li a{text-align:left;  text-decoration:none; color:#cc0000;}
.groupquyus_exam_room ul li a:hover{text-align:left; text-decoration:underline; color:#cc0000;}
/*Subject teacher comment*/
#stcommentmain{width:710px; height:auto; padding-top:20px;}
#stcommentmain input {background-color: #FFFFEA;}
.stcommenttop{width:710px; height:30px; line-height:30px; padding-top:1px;padding-bottom:1px; }
.stcommenttopinfo_l{ width:100px; height:25px; line-height:25px;float:left;border:1px solid #cccccc;padding-left:2px;background-color:#e0eef5;font-weight:bold;}
.stcommenttopinfo{ width:100px; height:25px; line-height:25px;float:left;border:1px solid #cccccc;padding-left:2px;background-color:#f0f0f0;}
.stcommentdes{width:710px; height:45px; line-height:45px; padding-top:2px;padding-bottom:3px;}
.stcommentdes_l{width:150px; height:43px; white-space:nowrap;padding-top:1px;float:left;border:1px solid #cccccc;padding-left:2px;background-color:#e0eef5;font-weight:bold;}
.stcommentdes_r{width:546px; height:43px; white-space:nowrap;padding-top:1px;float:left;border:1px solid #cccccc;padding-left:2px;background-color:#f0f0f0;}
.stcommentdesinfo { font-size: 15px; overflow:visible;background-color: #FFFFEA; border:1px solid #CCCCCC;color: black; padding-top:2px;padding-right:5px;padding-left:5px;font-family:arial,"ËÎÌå";width:98%;height:98%; letter-spacing:0; line-height:15px;} 
.alert{border: 1px solid transparent;border-radius: 4px;margin-bottom: 20px;padding: 5px;font-size:15px;}
.alert-info {background-color: #d9edf7;border-color: #bce8f1;color: #31708f;}
.alert-success {background-color: #dff0d8;border-color: #d6e9c6;color: #3c763d;}
.alert-warning {background-color: #fcf8e3;border-color: #faebcc;color: #8a6d3b;}
.alert-error {background-color: #f2dede;border-color: #ebccd1;color: #a94442;}


/*recruit management Ê¹ÓÃ×´Ì¬, 0 Îª¿ÕÏÐ£¬1ÎªÃæÊÔÖÐ,2ÎªÑ§ÉúÈ¥ÃæÊÔÍ¾ÖÐ,-1 ÐÝÏ¢ÖÐ*/
.room_state_bg_-1{background-color:#bc9364;}
.room_state_bg_0{background-color:#339999;}
.room_state_bg_1{background-color:#DB4A37;}
.room_state_bg_2{background-color:#f0bf00;}
.room_state_bg_3{background-color:#003366;}

/* div like table */
.dlist {width:100%;height:auto;text-align:center;}
.dlist ul{padding:0px;width:100%;border-bottom:1px solid #a94442;}
.dlist li{float:left;padding:0px;line-height:20px;word-wrap:break-word;overflow:hidden;}
.dlist ul.ul_head{background-color:gray;height:45px;line-height:45px;}
.dlist ul.ul_head li{height:45px;line-height:45px;}
.dlist ul:hover{background-color:#D4D4D4;}

/*circle popup*/
.circle{position:absolute;z-index:100;top:-15px;right:-2px;font-size:18px;font-weight:bold;color:white;text-align:center; box-shadow: 0 3px 2px 1px rgba(0,0,0,0.4);-moz-box-shadow: 0 3px 2px 1px rgba(0,0,0,0.4);-webkit-box-shadow: 0 3px 2px 1px rgba(0,0,0,0.4);background:red;width:32px;height:32px; line-height:32px; overflow:hidden; border-radius:25px;-moz-border-radius:25px; /* 老的 Firefox */-webkit-border-radius: 15px; /* Safari and Chrome */behavior: url(/static/css/ie-css3.htc);}

/*arrow*/
.arr_right_red{background:url(/static/images/pic/eg_arrow.gif) no-repeat left center; width:10px; height:10px;padding-left:12px;}
.arr_right{background:url(/static/images/gif-0865.gif) no-repeat left center; width:10px; height:10px;padding-left:10px;}
.arr_up{background:url(/static/images/jt3.gif) no-repeat left center; width:10px; height:10px;padding-left:10px;}

/*alert*/
.alert-div{background-color:#666666;position:fixed;z-index:99;left:0;top:0;display:none;width:100%;height:100%;opacity:1.0;filter:alpha(opacity=100);-moz-opacity:1.0;}
.alert {width:50%;padding: 20px;background-color: #f44336;color: white;opacity: 1;transition: opacity 0.6s;margin:10% auto;}
.alert-category{font-weight: bold;font-size: 24px;}
.alert.success {background-color: #4CAF50;}
.alert.info {background-color: #2196F3;}
.alert.warning {background-color: #ff9800;}
.closebtn {margin-left: 15px;color: white;font-weight: bold;float: right;font-size: 22px;line-height: 20px;cursor: pointer;transition: 0.3s;}
.closebtn:hover {color: black;}

/*下拉菜单*/
.dropdown{position:relative;}
.dropdown span{color:#D10005;font-weight: bold;}
.dropdown:hover .dropdown-content {display: block;}
.dropdown-content{display: none;position: absolute;background-color: #fff;box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);z-index: 1;width:100%;margin-left:-10px;}
.dropdown-content div{color:#777;background-color:#eee;margin-top:1px;text-align: center;}
.dropdown-content div.on{background-color: #AB363A;color:#fff;}
.dropdown-content div:hover{background-color: #891417;color:#fff;cursor: pointer;}

/*进程条*/
.process-bar{position: relative; width: 100%;}
.process-node{position: relative; float:left;margin-left:-1em;}
.process-node .content{float:left;line-height: 1.4em;font-size:1.0em;padding-left: 0.5em;padding-right: 0.5em;background-color: #ccc;text-align: center;}
.process-node.on .content{background-color: #FF9900;}
.process-node.ov .content{background-color: #339999;}
.process-node.error .content{background-color: #FF0033;}
.process-node .left-triangle{width: 0;height: 0;border-left: 1.4em solid transparent; border-top: 1.4em solid #ccc;border-bottom: 1.4em solid #ccc; float: left;}
.process-node.on .left-triangle{width: 0;height: 0;border-left: 1.4em solid transparent; border-top: 1.4em solid #FF9900;border-bottom: 1.4em solid #FF9900; float: left;}
.process-node.ov .left-triangle{width: 0;height: 0;border-left: 1.4em solid transparent; border-top: 1.4em solid #339999;border-bottom: 1.4em solid #339999; float: left;}
.process-node.error .left-triangle{width: 0;height: 0;border-left: 1.4em solid transparent; border-top: 1.4em solid #FF0033;border-bottom: 1.4em solid #FF0033; float: left;}
.process-node .right-triangle{width: 0;height: 0;border-left: 1.4em solid #ccc; border-top: 1.4em solid transparent;border-bottom: 1.4em solid transparent; float: left;}
.process-node.on .right-triangle{width: 0;height: 0;border-left: 1.4em solid #FF9900; border-top: 1.4em solid transparent;border-bottom: 1.4em solid transparent; float: left;}
.process-node.ov .right-triangle{width: 0;height: 0;border-left: 1.4em solid #339999; border-top: 1.4em solid transparent;border-bottom: 1.4em solid transparent; float: left;}
.process-node.error .right-triangle{width: 0;height: 0;border-left: 1.4em solid #FF0033; border-top: 1.4em solid transparent;border-bottom: 1.4em solid transparent; float: left;}

/*弹出层*/
.faqbg{background-color:#666666;position:fixed;z-index:99;left:0;top:0;display:none;width:100%;height:1000px;opacity:0.5;filter:alpha(opacity=50);-moz-opacity:0.5;}
.faqdiv{position:fixed;width:600px;left:50%;top:35%;margin-left:-300px;height:auto;z-index:100;background-color:#fff;-moz-box-shadow: 5px 5px 10px #555; /* 老的 Firefox */box-shadow: 5px 5px 10px #555;border:0;}
.faqdiv h2{width:100%;height:25px;font-size:14px;background-color:#555;position:relative;line-height:25px;color:white;margin:0px;}
.faqdiv h2 a{position:absolute;right:5px;font-size:12px;color:#FF0000;}
.faqdiv .info{padding:10px;}

.cover-bg{background: rgba(85,85,85,0.8);position: fixed;width: 100%;height: 100%;top:0px;left: 0px; z-index: 9999;display: none;}
.cover-content{position: relative;background: rgba(255, 255, 255, 1.0);margin:2em auto; width: 960px;height: auto;min-height: 10em;}

/*特定操作按钮*/
.action-button{width: 150px;background: #339999;font-weight: bold;color: white;border: 0 none;border-radius: 1px;cursor: pointer;margin: 10px 5px; line-height: 34px;}
.action-button:hover, .action-button:focus {box-shadow: 0 0 0 2px white, 0 0 0 3px #339999;}
.hold-button{width: 150px;background: #FF9900;font-weight: bold;color: white;border: 0 none;border-radius: 1px;cursor: pointer;margin: 10px 5px; line-height: 34px;}
.hold-button:hover, .hold-button:focus {box-shadow: 0 0 0 2px white, 0 0 0 3px #FF9900;}
.reject-button{width: 150px;background: #FF0033;font-weight: bold;color: white;border: 0 none;border-radius: 1px;cursor: pointer;margin: 10px 5px; line-height: 34px;}
.reject-button:hover, .reject-button:focus {box-shadow: 0 0 0 2px white, 0 0 0 3px #FF0033;}
.purple-button{width: 150px;background: purple;font-weight: bold;color: white;border: 0 none;border-radius: 1px;cursor: pointer;margin: 10px 5px; line-height: 34px;}
.purple-button:hover, .purple-button:focus {box-shadow: 0 0 0 2px white, 0 0 0 3px purple;}
.link-button {width: 150px;background: #bc9364;font-weight: bold;color: white;border: 0 none;border-radius: 1px;cursor: pointer;margin: 10px 5px; line-height: 34px;}
.link-button:hover, .link-button:focus {box-shadow: 0 0 0 2px white, 0 0 0 3px #bc9364;}
.gray-button {width: 150px;background: gray;font-weight: bold;color: white;border: 0 none;border-radius: 1px;cursor: pointer;margin: 10px 5px; line-height: 34px;}
.gray-button:hover, .link-button:focus {box-shadow: 0 0 0 2px white, 0 0 0 3px gray;}
.action-button[disabled], .action-button[disabled]:active, .action-button[disabled]:focus, .action-button[disabled]:hover {background-color: #A4D9D3;color: #fff;}
.reject-button[disabled], .reject-button[disabled]:active, .reject-button[disabled]:focus, .reject-button[disabled]:hover {background-color: #F9A09A;color: #fff;}
.button-div{position: relative;}
.button-cover{position:absolute;top:0;left:0;float:none;height:100%;width:100%;line-height: inherit;background:rgba(255,255,255,0.5);color:#555;z-index:99;margin: 10px 5px; line-height: 34px;}
.rotate45{transform: rotate(45deg);}
.rotate90{transform: rotate(90deg);}
.rotate135{transform: rotate(135deg);}
.rotate180{transform: rotate(180deg);}
.rotate225{transform: rotate(225deg);}
.rotate270{transform: rotate(270deg);}
.rotate315{transform: rotate(315deg);}
.gradient-bg-180{background-image: linear-gradient(180deg, #003399, #CC0033);color: #FFF;}
#blockCity{ position:absolute;font-size:9pt;  background-color:#FFFFCC; padding:5px; border:1px solid #F5C66B;line-height:160%; width:auto; display:none;}

.rightbar1>#leaders1>ul>.sec1:nth-child(1),
.rightbar1>#leaders1>ul>.sec1:nth-child(3) {
  display: none!important;
}


.searchable-select-holder, .searchable-select-dropdown, .searchable-has-privious {
  background-color: $cardHeadColorCss !important;
}

option {
  background-color: $cardHeadColorCss !important;
  color: $onSurfaceCss !important;
}

.main1_w100>.main1_w100.noprint {
  display: none!important;
}

.main1>.main1.noprint,
.leftbar>.login>.a12.top5.t_right,
header .ant-space.ant-space-horizontal.ant-space-align-center.ant-space-gap-row-small.ant-space-gap-col-small.ant-dropdown-trigger:nth-child(3) {
  display: none!important;
}

.main1>.leftbar>.logo>a {
  pointer-events: none!important;
}

.list-group-item > a {
  color: $onSurfaceCss !important;
}

.category-block{display:inline-block;margin-left:10px; margin-top:10px; background-color:$cardHeadColorCss !important;color:#555;height:130px;text-align: center;cursor: pointer; line-height: 2.15em;}
.category-block.available{background-color:$primaryColorCssTransparent !important;color:#FFF;}
.category-block.available.other{background-color: #f0bf00 !important;color: #FFF;}
.category-block .t_right{margin-right: 5px;}
.category-block .title{font-size:1.5em;}
.category-block .themes{font-size:0.9em;font-weight: normal;line-height: 1.5em;}
`));
(document.head || document.documentElement).appendChild(s);
// Observer for ant-layout-header creation
const headerObserver = new MutationObserver((mutations) => {
  mutations.forEach((mutation) => {
    mutation.addedNodes.forEach((node) => {
      if (node.nodeType === Node.ELEMENT_NODE) {
        // Check if the added node is the header itself
        if (node.classList && node.classList.contains('ant-layout-header')) {
          applyHeaderStyles(node);
        }
        // Check if the added node contains the header
        const header = node.querySelector && node.querySelector('.ant-layout-header');
        if (header) {
          applyHeaderStyles(header);
        }
      }
    });
  });
});

// Function to apply header styles
function applyHeaderStyles(header) {
  console.log(header);
  header.style.backgroundImage = 'none';
  header.style.background = 'none';
  header.style.height = '64px';
  // Remove color attribute from all anchor tags
  console.log(header.querySelectorAll("a"));
  header.querySelectorAll("a").forEach(el => {
    console.log(el);
    el.removeAttribute("color");
    el.style.color = '';
  });
}

// Start observing
headerObserver.observe(document.body, {
  childList: true,
  subtree: true
});

// Also check if header already exists
const existingHeader = document.querySelector('.ant-layout-header');
if (existingHeader) {
  applyHeaderStyles(existingHeader);
}

const footer = document.querySelector('.ant-layout-footer');
if (footer) {
  footer.style.backgroundImage = 'none';
  footer.style.background = 'none';
}

const content = document.querySelector('.site-layout-content');
if (content) {
  content.removeAttribute("style");
}

document.querySelectorAll(".part_uae.m_bottom5, .ct2.a12.b, #msform, .main1.noprint, .top20.t_12").forEach(el => {
  el.removeAttribute("style");
});

if(window.location.pathname.includes("/user/")) {
  document.querySelectorAll("th, td").forEach(el => {
    el.style.backgroundColor = 'transparent';
  });
  document.querySelectorAll("tr").forEach(el => {
    el.style.backgroundColor = 'transparent';
    el.bgColor = 'transparent';
  });
}


}
ensure2();
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', ensure2);
} else {
  ensure2();
}
        ''';
}
