import 'package:flutter/material.dart';

String zeroBodyMarginStyle() {
  return '''
          var s = document.createElement('style');
          s.id = 'ocms-css-inject-zero-body-margin';
          s.type = 'text/css';
          s.appendChild(document.createTextNode(`
            .leftbar, #leaders1, .btop.a12, .main1>.main1.noprint, .btop, .photo1.m_left, .mae_tok.a12 {display:none!important;}
            .main1, .rightbar1, .ctbody1, .meair_lef {width:100%!important;margin: 0!important;}
            
          `));
          (document.head || document.documentElement).appendChild(s);
        ''';
}

String convertColorToCss(Color color) {
  return 'rgba(${color.r * 255}, ${color.g * 255}, ${color.b * 255}, ${color.a})';
}

String webCmsStyle(BuildContext context) {
  final darkCardColorCss = convertColorToCss(
    Theme.of(context).colorScheme.surfaceContainerLow,
  );
  final primaryColorCssTransparent = convertColorToCss(
    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
  );
  final cardHeadColorCss = convertColorToCss(
    Theme.of(context).colorScheme.surfaceContainerHigh,
  );
  final primaryColorCss = convertColorToCss(
    Theme.of(context).colorScheme.primary,
  );
  final onSurfaceCss = convertColorToCss(
    Theme.of(context).colorScheme.onSurface,
  );
  final surfaceColorCss = convertColorToCss(
    Theme.of(context).colorScheme.surface,
  );
  final isDarkMode =
      Theme.of(context).colorScheme.brightness == Brightness.dark;
  return '''
// Inject critical CSS immediately to prevent flickering
(function() {
  if(document.querySelector('#ocms-css-inject')) return;
  
  var criticalStyle = document.createElement('style');
  criticalStyle.id = 'ocms-critical-css';
  criticalStyle.type = 'text/css';
  criticalStyle.appendChild(document.createTextNode(`
html { color-scheme: ${isDarkMode ? 'dark' : 'light'} !important; }
body { background-color: transparent !important; }
.ant-layout { background-color: transparent !important; }
.ant-layout-header { background-color: $cardHeadColorCss !important; }
.ant-card-bordered, .ant-breadcrumb, .navbar-inner, .list-group-item, .main_tops, .red { 
  background-color: $darkCardColorCss !important; 
  border: none !important; 
}
html, .ant-layout,
.ant-descriptions-view td {
    background-color: transparent !important;
}
html {
    color-scheme: ${isDarkMode ? 'dark' : 'light'} !important;
}
html, body, input, textarea, select, button, dialog {
    background-color: transparent
}
  `));
  (document.head || document.documentElement).appendChild(criticalStyle);
  
  var s = document.createElement('style');
  s.id = 'ocms-css-inject';
  s.type = 'text/css';
  s.appendChild(document.createTextNode(`
.jfk-bubble.gtx-bubble, .captcheck_answer_label > input + img, span#closed_text > img[src^="https://www.gstatic.com/images/branding/googlelogo"], span[data-href^="https://www.hcaptcha.com/"] > #icon, #bit-notification-bar-iframe, ::-webkit-calendar-picker-indicator {
    filter: invert(100%) hue-rotate(180deg) contrast(90%) !important;
}
input:-webkit-autofill,
textarea:-webkit-autofill,
select:-webkit-autofill {
    background-color: #404400 !important;
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
.certification-div{background-color: $cardHeadColorCss!important; background-image: none !important; }
.btn {background-color: $cardHeadColorCss !important;}
.submenu {background-color: $cardHeadColorCss !important;}

#leaders1{background:$darkCardColorCss;width:730px;padding:8px 0px 6px!important;padding:8px 0 0 0;}
.rightbar1_w{width:749px;float:left;}
#leaders1_w{background:$darkCardColorCss;width:730px;padding:8px 0px 6px!important;padding:8px 0 0 0;}
#leaders1_w100{background:$darkCardColorCss;width:80%;padding:8px 0px 6px!important;padding:8px 0 0 0;}
.allexam_cor1{margin-bottom:10px;background:#eeeeee;padding-left:60px;padding-top:0px !important;padding-top:5px;padding-bottom:0px !important;padding-bottom:5px;}
.cours_paiu1{position:relative;top:230px;padding-left:640px !important;padding-left:633px;}
.cours_paiu11{position:relative;top:125px;padding-left:640px !important;padding-left:633px;}
.part_uae1{margin-bottom:10px;background:$primaryColorCssTransparent;line-height:25px;padding-left:5px;border-top:1px solid $primaryColorCss}
.part_cae1{margin-bottom:10px;background:$primaryColorCssTransparent;line-height:25px;padding-left:5px;border-top:1px solid $primaryColorCss;}
.att_b{background:$primaryColorCss;color:#ffffff;padding:0 3px;line-height:14px;text-align:center;margin-right:3px;}
th{padding:0px 0px;background:$cardHeadColorCss;text-align:center; color: $onSurfaceCss;}
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
.c2{color:$primaryColorCss;}
.c3{color:$primaryColorCss;}
.cg{color:$primaryColorCss}
.cf{color:$onSurfaceCss;}
.ca{color:$cardHeadColorCss;}
.cd{color:$onSurfaceCss;}
.cc{color:$cardHeadColorCss;}
.ce{color:#ff0000;}
.ex{color:$primaryColorCss;}
.ee{color:$cardHeadColorCss;}
.red{color:red;}
.green{color:$primaryColorCss;}
.f5{color:$darkCardColorCss;}
.ed{color:#f57489}
.nae{color:$primaryColorCss}
.backg{background:$onSurfaceCss;}
.bahs{background:$cardHeadColorCss;}
.pink{background:#ffeeee;}

.f_rights{width:288px;background:$cardHeadColorCss; float:right; padding-left:420px; height:40px; line-height:40px;}

a:link{text-decoration:none;color:$primaryColorCss;font-size:14px;}
a:visited{text-decoration:none;color:$primaryColorCss;font-size:14px;}
a:hover{text-decoration:underline;color:$primaryColorCss;font-size:14px;}
#leader a:hover{display:block;float:left;padding:0px 10px;margin-right:10px;text-decoration:none;color:#ffffff;font-size:14px;background:$primaryColorCss;line-height:22px;}
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
.ac a:link{text-decoration:underline;color:$primaryColorCss;font-size:12px;}
.ac a:visited{text-decoration:underline;color:$primaryColorCss;font-size:12px;}
.ac a:hover{text-decoration:underline;color:$primaryColorCss;font-size:12px;}
.ac14 a:link{text-decoration:none;color:$primaryColorCss;font-size:14px;}
.ac14 a:visited{text-decoration:none;color:$primaryColorCss;font-size:14px;}
.ac14 a:hover{text-decoration:underline;color:$primaryColorCss;font-size:14px;}
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

.bg_9F9{background-color:#9F9F9F;}/*淡灰*/ .bg_e1f{background-color:#e1f9fd;}/*浅蓝*/ .bg_fff{background-color:#fff;}/*白*/    .bg_ccc{background-color:#ccc;}/*灰*/ 
.bg_f0f{background-color:#f0f0f0;}/*浅灰*/ .bg_006{background-color:#006699;}/*蓝*/   .bg_ff0{background-color:#ff0000;}/*红*/ .bg_cc0{background-color:#cc0000;}/*深红*/ 
.bg_f9f{background-color:$cardHeadColorCss;}/*浅灰*/.bg_f009{background-color:#009900;}/*绿*/.bg_f06{background-color:#006600;}/*深绿*/

.BG_COLOR_1{background-color:#ffffff;} .BG_COLOR_2{background-color:$cardHeadColorCss;}

.logo{padding:5px;border-bottom:8px solid $primaryColorCss;background:$darkCardColorCss}
.login{background:$cardHeadColorCss;padding:15px;border-bottom:1px solid $cardHeadColorCss}
.input_login{width:140px;border:1px solid $cardHeadColorCss;height:18px;margin-top:10px;}
.bur_login{width:118px;border:1px solid $cardHeadColorCss;height:18px;margin-top:10px;margin-left:15px;margin-right:5px;}
.bt_login{background:$darkCardColorCss;color:#ffffff;line-height:16px;margin-top:10px;padding:0px 10px;border:1px solid #560D0F;border-top-color:#CD6366;border-left-color:#CD6366}
.bar_login{background:$darkCardColorCss;color:#ffffff;line-height:16px;margin-top:10px;padding:0px 5px;border:1px solid #560D0F;border-top-color:#CD6366;border-left-color:#CD6366}
#leader{background:$darkCardColorCss;width:570px;padding:6px 0px 6px;}
#leaders{background:$darkCardColorCss;width:570px;padding:8px 0px 6px!important;padding:8px 0 0 0;}
.ctbody{border:1px solid #B8B8B8;width:588px;}
.btop{background:$cardHeadColorCss;border-top:1px solid $onSurfaceCss;border-bottom:1px solid $cardHeadColorCss;height:46px;}
.photo{height:100%;width:150px;margin-left:20px;position:relative;top:-20px;border:1px solid $cardHeadColorCss;padding:5px;background:#ffffff;}
.photo2{float:right;width:150px;margin-right:20px;display:inline;position:relative;top:-20px;border:1px solid $cardHeadColorCss;padding:5px;background:#ffffff;}
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
.yearlist{background:transparent; border-bottom: 1px solid $primaryColorCss;}
.yearlist_top{background:transparent; border-top: 1px solid $primaryColorCss;}
.studentgpa{background:$cardHeadColorCss repeat-x bottom; padding:0px 0px 0px 10px;}
.actyear{font-size:12px;font-weight:bold;color:$primaryColorCss;float:right;border:1px solid #BB5557;border-bottom:1px solid #F2ABAD;padding:0px 10px;line-height:24px;margin-right:5px;background:#F2A7A8 url('/static/images/bgyear.gif') repeat-x top;}
.actyear_mor{font-size:12px;font-weight:bold;color:$primaryColorCss;float:right;border:1px solid #BB5557;border-bottom:1px solid #F2ABAD;padding:0px 10px;line-height:24px;margin-right:5px;background:#F2A7A8 url('/static/images/bgyear_mor.gif') repeat-x top;}
.actyear_eve{font-size:12px;font-weight:bold;color:$primaryColorCss;float:right;border:1px solid #BB5557;border-bottom:1px solid #F2ABAD;padding:0px 10px;line-height:24px;margin-right:5px;background:#F2A7A8 url('/static/images/bgyear_eve.gif') repeat-x top;}
.ste_eve{font-size:12px;font-weight:bold;color:$primaryColorCss;float:left;border:1px solid #BB5557;border-bottom:1px solid #F2ABAD;padding:0px 10px;line-height:24px;margin-right:5px;background:#F2A7A8 url('/static/images/bgyear_eve.gif') repeat-x top;}
.actmonth{float:left;width:45px;text-align:center;line-height:28px;background:url('/static/images/bgactmonth.gif') no-repeat 8px 4px;color:$primaryColorCss;font-size:12px;font-weight:bold}
.cqlkk{height:20px;padding:1px;border:1px solid $cardHeadColorCss;float:left;width:400px;}
.cqlvalue{line-height:24px;font-size:14px;color:$primaryColorCss;font-weight:bold;margin-left:5px;}
.cloudinfo{text-align:left;background:$darkCardColorCss;padding:20px 20px 20px 50px;color:#ffffff;font-size:25px;font-weight:bold;border-bottom:8px solid #FF9696}
.subjectname{color:$primaryColorCss;font-size:25px;}
.subjectlo{color:$primaryColorCss;font-size:16px;}
.bacofyv{border-bottom:1px solid $primaryColorCss;}

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
.byyear1{color:$cardHeadColorCss;font-size:30px;font-family:Arial;float:right;margin:10px 10px 10px 30px;}
.sname a:link{text-decoration:none;color:$primaryColorCss;font-size:14px;font-size:25px;font-weight:bold;}
.sname a:visited{text-decoration:none;color:$primaryColorCss;font-size:14px;font-size:25px;font-weight:bold;}
.sname a:hover{text-decoration:underline;color:$primaryColorCss;font-size:14px;font-size:25px;font-weight:bold;}
.reverse a:link{text-decoration:none;color:$primaryColorCss;font-size:12px;}
.reverse a:visited{text-decoration:none;color:$primaryColorCss;font-size:12px;}
.reverse a:hover{text-decoration:underline;color:$primaryColorCss;font-size:12px;}
.subjectname1{color:$primaryColorCss;font-size:18px;}
.fone_r{color:$primaryColorCss;font-size:16px;}
.bdaef{color:$primaryColorCss;font-weight:bold;height:30px;background:#E6E2E2;}
.sdfhiw1{font-family:'arial';color:#666666;height:24px;text-align:center;background:$cardHeadColorCss;border:1px solid #F4F2F2;}
.schname a:link{text-decoration:none;font-size:16px;color:$primaryColorCss;font-weight:bold}
.schname a:visited{text-decoration:none;font-size:16px;color:$primaryColorCss;font-weight:bold}
.schname a:hover{text-decoration:none;font-size:16px;color:$primaryColorCss;font-weight:bold}
.login_hy{padding-left:25px;padding-top:15px;background:$cardHeadColorCss;line-height:12px;}
.input_logins{width:60px;border:1px solid $cardHeadColorCss;height:18px;margin-bottom:5px !important;margin-bottom:0px ;position:relative;top:-2px;}
.input_logint{width:140px;border:1px solid $cardHeadColorCss;height:18px;margin-top:10px;}
.part_top{margin-bottom:5px;background:$cardHeadColorCss;line-height:25px;padding-left:5px;}
.part_right{margin-bottom:12px;background:$cardHeadColorCss;line-height:25px;padding-left:5px;margin-top:33px}
.part_uae{margin-bottom:10px;background:$primaryColorCssTransparent;line-height:25px;padding-left:5px;border-top:1px solid $primaryColorCss}
.part_cae{margin-top:40px;margin-bottom:10px;background:$primaryColorCssTransparent;line-height:25px;padding-left:5px;border-top:1px solid $primaryColorCss;}
.part_ct{margin-top:40px;margin-bottom:12px;background:$primaryColorCssTransparent;line-height:25px;padding-left:5px;border-top:1px solid $primaryColorCss;}
.part_bj a:hover{text-decoration:none;color:#ffffff;background:$primaryColorCss;font-size:12px;}
.input_pr{border:1px solid $cardHeadColorCss;height:16px;margin-top:10px;width:20px;}
.presde_tion{background:$cardHeadColorCss;padding-top:3px;border-top:1px solid #cccccc;line-height:20px;margin-top:5px;}
.cqlks{height:20px;padding:1px;border:1px solid $cardHeadColorCss;float:left;width:360px;}
.caefaye{display:block;line-height:22px;border-top:2px solid $primaryColorCss;border-bottom:2px solid $primaryColorCss;width:140px;float:left;color:#8A8585;margin-top:8px;margin-bottom:1px;margin-right:10px;padding:10px 0px;}
.mae a:link{text-decoration:none;color:$primaryColorCss;font-size:12px;}
.mae a:visited{text-decoration:none;color:$primaryColorCss;font-size:12px;}
.mae a:hover{text-decoration:none;color:#ffffff;background:$primaryColorCss;font-size:12px;}
.input_con{width:140px;border:1px solid $cardHeadColorCss;height:18px;}
.aexb{width:100%;border-collapse:collapse;border:1px solid $cardHeadColorCss;line-height:20px;}
.searxb{width:100%;border-collapse:collapse;border:0px solid $cardHeadColorCss;line-height:20px;}
.aexbs{width:60%;border-collapse:collapse;border:1px solid $cardHeadColorCss;line-height:20px;}
.tafeyl_ay{border-right:1px solid #ffffff;border-bottom:1px solid $cardHeadColorCss; color: $onSurfaceCss;}
.middle_div_style{position:absolute; top:50%; left:50%;background:$cardHeadColorCss;border:1px solid #ff8800;padding:10px;line-height:20px;display:none;}
.rywft_dev{margin-bottom:5px;background:$cardHeadColorCss;line-height:25px;padding-left:5px;width:153px;}
.sn_div{background:$primaryColorCss;color:#ffffff;padding:3px;line-height:18px;text-align:center;margin:3px;display:inline;}
.wiveye{float:left;background:$primaryColorCss;color:#ffffff;padding:0 3px;line-height:14px;text-align:center;margin-right:3px;}
.wiveye_span{background-color:$primaryColorCss;color:#ffffff;padding:3px;line-height:14px;text-align:center;margin-right:3px;}
.wiveye_span2{background-color:$primaryColorCss;color:#ffffff;padding:3px;line-height:14px;text-align:center;margin:1px;display:inline-block;}
.normal_td_t30{background-color:$surfaceColorCss; color: $onSurfaceCss !important;}
.normal_td, td{background-color: transparent!important;vertical-align: bottom; color: $onSurfaceCss !important;}
textarea {background-color: $darkCardColorCss;}
div.istw .ws-div{color:$primaryColorCss;}
div.isntw .ws-div{color:#aaa;}
.kajyve{display:block;padding:7px 2px 5px 15px;background:$primaryColorCss;float:left;line-height:18px;height:20px !important;height:18px;color:#ffffff;margin-right:20px;margin-bottom:10px;}
.chjyve{display:block;padding:7px 15px 5px 15px;background:#2606cd;float:left;line-height:18px;height:20px !important;height:18px;color:#ffffff;margin-right:20px;margin-bottom:10px;}
.chjyhs{display:block;padding:7px 15px 5px 15px;background:$primaryColorCss;float:left;line-height:18px;height:20px !important;height:18px;color:#ffffff;margin-right:20px;margin-bottom:10px;}
.tinfoay{background:$primaryColorCssTransparent;padding:10px 10px 0px 10px;height:auto !important;height:68px;min-height:69px;}
.tinfotoy{padding:3px;border:1px solid $cardHeadColorCss;background:#ffffff;width:50px;}
.tiveye{float:left;background:$primaryColorCss;color:#ffffff;padding:0 3px;line-height:14px;text-align:center;margin-right:3px;}
.skauyv{background:$cardHeadColorCss;}
.skau_scw{background:$cardHeadColorCss;line-height:5px;}
.skauyv_scwk{background:$cardHeadColorCss;padding:5px 0;line-height:22px;}
.qtaiyv{float:left;background:$primaryColorCss;color:#ffffff;line-height:20px;padding:0 2px;}
.aiyeae{float:left;background:$primaryColorCss;color:#ffffff;line-height:14px;padding:0 2px;margin-right:5px;}
.dealk{background:$cardHeadColorCss;}
.mytdbj{background:$cardHeadColorCss;width:688px;padding:0 10px;}
.morning{background:$cardHeadColorCss;width:688px;padding:0 10px 5px 10px;}
.uavyes{background:$cardHeadColorCss;padding:0 10px;width:380px;margin: 0 auto;}
.wkaiyvw{float:left;padding-left:3px;padding-right:5px;line-height:17px;border:1px solid $cardHeadColorCss;}
.taeiyv_bj_11per,.taeiyv_bj1{background:$primaryColorCssTransparent !important;}
.adfev{font-size:12px;font-weight:bold;color:$primaryColorCss;float:right;border:1px solid $primaryColorCss;border-bottom:1px solid #F2ABAD;padding:0px 10px;line-height:24px;margin-right:5px;background:$primaryColorCssTransparent !important;}
.evwear{float:right;border:1px solid #cccccc;border-bottom:0px;padding:0px 10px;line-height:24px;margin-right:5px;background:transparent !important;}
.evwear_1{float:right;border:1px solid #cccccc;padding:0px 10px;line-height:24px;margin-right:5px;background:$cardHeadColorCss !important;}
.seeyve{background:$primaryColorCss;background: radial-gradient(#efefef, #FF0033);}
.accordion {
  width: 100%;
  /*max-width: 360px;*/
  margin: 30px auto 20px;
  background: $darkCardColorCss !important;
  -webkit-border-radius: 4px;
  -moz-border-radius: 4px;
  border-radius: 4px;
}

.bgone{background-color:$cardHeadColorCss; width:100%;}
#search_sea{width:100%; height:50px; line-height:30px; border-top:0px; border-left:0px; border-right:0pox; border-bottom:1px solid #cccccc; background:$cardHeadColorCss;}
.return ul li a:hover{font-size:12px; color:#cc0000; text-decoration:underline; line-height:30px; border:1px solid #CCCCCC; padding:2px 5px 2px 5px; background-color:$cardHeadColorCss;}
.msntitle{width:100%; height:auto; border:1px solid #cccccc; background-color:$cardHeadColorCss; line-height:30px;}

.alert{border: 1px solid transparent;border-radius: 4px;margin-bottom: 20px;padding: 5px;font-size:15px;}

.rightbar1>#leaders1>ul>.sec1:nth-child(1),
.rightbar1>#leaders1>ul>.sec1:nth-child(3) {
  display: none!important;
}
#leaders1 a:link{color: $onSurfaceCss !important;}
#headerwrap h1 {color: $onSurfaceCss !important;}

.sec2 {
  background-color: $primaryColorCss !important;
  color: white!important;
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

.submit_3big {
  background-color: $primaryColorCssTransparent !important;
  border-color: $primaryColorCss !important;
}

#headerwrap {
  background: none !important;
}

.category-block{display:inline-block;margin-left:10px; margin-top:10px; background-color:$primaryColorCssTransparent !important;color:$onSurfaceCss !important;height:130px;text-align: center;cursor: pointer; line-height: 2.15em;}
.category-block.available{background-color:$primaryColorCssTransparent !important;color:#FFF;}
.category-block.available.other{background-color: #primaryColorCssTransparent !important;color: #FFF;}
.category-block .t_right{margin-right: 5px;}
.category-block .title{font-size:1.5em;}
.category-block .themes{font-size:0.9em;font-weight: normal;line-height: 1.5em;}

.dropdown-menu, .bootstrap-select.btn-group .no-results, .ui-widget-header{background-color: $cardHeadColorCss !important;}
.ui-widget-content{background-color: $darkCardColorCss !important;}
.modern-forms .mdn-input, .modern-forms .mdn-select-multiple select, .modern-forms .mdn-select>select, .modern-forms .mdn-textarea{
  color: $onSurfaceCss !important;
}

.ui-state-default{background-color: $cardHeadColorCss !important;color: $onSurfaceCss !important;border: none !important;}


.ghomenpi>div>a>img{filter: contrast(80%) !important;opacity: 0.9 !important;}
${isDarkMode ? '.ghomenpi>div>a>img{filter: invert(100%) hue-rotate(180deg) contrast(70%) !important;opacity: 0.8 !important;}' : ''}

.logo>a>img {
  ${isDarkMode ? '' : 'filter: invert(90%) !important;'}
}

.brand{
  ${isDarkMode ? '' : 'filter: invert(90%) !important;'}
}

font{color: $onSurfaceCss;}

#calendar_page_0 table tr th{color: $onSurfaceCss !important;}

.action-button, .modern-forms .btn-primary{background-color: $primaryColorCss !important;}

#TB_window{background-color: $darkCardColorCss !important;}
#TB_title{background-color: $cardHeadColorCss !important;}
.td-title{background-color: $darkCardColorCss !important;}

.ca{color: $onSurfaceCss !important;}
.font_attpik{color: $onSurfaceCss !important;}
`));
  (document.head || document.documentElement).appendChild(s);
})();

var ensure2 = function() {
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
          // Check if the added node is within an existing header
          const parentHeader = node.closest && node.closest('.ant-layout-header');
          if (parentHeader) {
            applyHeaderStyles(parentHeader);
          }
          // Check if the added node is a table element
          if (node.tagName === 'TR' || node.tagName === 'TD' || node.tagName === 'TH') {
            node.style.backgroundColor = 'transparent';
            node.bgColor = 'transparent';
          }
          // Check if the added node contains table elements
          if (node.querySelectorAll) {
            node.querySelectorAll("tr, td, th").forEach(el => {
              el.style.backgroundColor = 'transparent';
              el.bgColor = 'transparent';
            });
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
      el.removeAttribute("color");
      el.style.color = '';
    });
    header.querySelectorAll("img").forEach(el => {
      ${isDarkMode ? '' : "el.style.filter = 'invert(90%)';"}
    });
  }

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

  document.querySelectorAll("td,th,tr").forEach(el => {
    el.style.backgroundColor = 'transparent';
    el.bgColor = 'transparent';
  });

  // Start observing
  headerObserver.observe(document.body, {
    childList: true,
    subtree: true
  });
}
ensure2();
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', ensure2);
}
''';
}
