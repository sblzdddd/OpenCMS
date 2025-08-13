/// HTML content for the Tencent Captcha verification interface
const String captchaHtmlContent = '''
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Web 前端接入示例</title>
  <!-- 验证码程序依赖(必须)。请勿修改以下程序依赖，如通过其他手段规避加载，会导致验证码无法正常更新，对抗能力无法保证，甚至引起误拦截。 -->
  <script src="https://turing.captcha.qcloud.com/TJCaptcha.js"></script>
</head>

<body style="">
<style>
  html, body {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100%;
    background-color: transparent;
  }
  .tencent-captcha__mask-layer {
    opacity: 0 !important;
  }
  #tencentCaptcha {
    color: white;
    opacity: 0.5;
  }
  .tencent-captcha__transform {
    border-radius: 16px;
  }
</style>
  <p id="tencentCaptcha">creating TencentCaptcha...</p>
</body>

<script>

  // 定义回调函数
  function callback(res) {
    // 第一个参数传入回调结果，结果如下：
    // ret         Int       验证结果，0：验证成功。2：用户主动关闭验证码。
    // ticket      String    验证成功的票据，当且仅当 ret = 0 时 ticket 有值。
    // CaptchaAppId       String    验证码应用ID。
    // bizState    Any       自定义透传参数。
    // randstr     String    本次验证的随机串，后续票据校验时需传递该参数。
    // verifyDuration     Int   验证码校验接口耗时（ms）。
    // actionDuration     Int   操作校验成功耗时（用户动作+校验完成）(ms)。
    // sid     String   链路sid。
    
    document.getElementById('tencentCaptcha').innerHTML = 'callback...';


    // res（用户主动关闭验证码）= {ret: 2, ticket: null}
    // res（验证成功） = {ret: 0, ticket: "String", randstr: "String"}
    // res（请求验证码发生错误，验证码自动返回trerror_前缀的容灾票据） = {ret: 0, ticket: "String", randstr: "String",  errorCode: Number, errorMessage: "String"}
    // 此处代码仅为验证结果的展示示例，真实业务接入，建议基于ticket和errorCode情况做不同的业务处理
    if (res.ret === 0) {
      // 复制结果至剪切板
        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            window.flutter_inappwebview.callHandler('captchaComplete', 'success', res);
        }
    } else {
        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
            window.flutter_inappwebview.callHandler('captchaComplete', 'error', res);
        }
    }
  }

  // 定义验证码js加载错误处理函数
  function loadErrorCallback() {
    var appid = '194431589';
    // 生成容灾票据或自行做其它处理
    var ticket = 'trerror_1001_' + appid + '_' + Math.floor(new Date().getTime() / 1000);
    callback({
      ret: 0,
      randstr: '@' + Math.random().toString(36).substr(2),
      ticket: ticket,
      errorCode: 1001,
      errorMessage: 'jsload_error'
    });
  }

  // 定义验证码触发事件
  window.onload = function () {
    try {
      // 生成一个验证码对象
      // CaptchaAppId：登录验证码控制台，从【验证管理】页面进行查看。如果未创建过验证，请先新建验证。注意：不可使用客户端类型为小程序的CaptchaAppId，会导致数据统计错误。
      //callback：定义的回调函数
      var captcha = new TencentCaptcha('194431589', callback, {userLanguage: 'en'});
      // 调用方法，显示验证码
      captcha.show();
    } catch (error) {
      // 加载异常，调用验证码js加载错误处理函数
      loadErrorCallback();
    }
  }
</script>

</html>
''';
