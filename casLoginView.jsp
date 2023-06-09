<!DOCTYPE html>
<%@ page pageEncoding="UTF-8" %>
  <%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
      <%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
        <%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
          <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <title>CAS登录系统</title>
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />

  <link rel="shortcut icon" href="images/logo.png" type="image/x-icon" />
  <!-- 引入axios -->
  <script type="text/javascript" src="js/axios.min.js"></script>
  <!-- 引入vue -->
  <script rel="stylesheet" type="text/javascript" src="js/vue@2.6.12.js"></script>
  <!-- 引入组件库 -->
  <script rel="stylesheet" type="text/javascript" src="js/element@2.15.6.js"></script>
  <!-- 引入rem -->
  <script rel="stylesheet" type="text/javascript" src="js/rem.js"></script>
  <!-- 引入配置文件 -->
  <script rel="stylesheet" type="text/javascript" src="js/config.js"></script>
  <script type="text/javascript" src="js/InfosecNetSignCNGAgent.min.js"></script>
  <!-- 引入样式 -->
  <link rel="stylesheet" type="text/css" href="css/element@2.15.6.css">
  <link rel="stylesheet" type="text/css" href="css/index.css">
  <link rel="stylesheet" type="text/css" href="css/base.css">
  <link rel="stylesheet" type="text/css" href="css/variables.css">
</head>

<body>
  <div id="app" class="app">
    <div class="login-wrapper">
      <div class="login-block">
        <div class="logo">
          <img src="images/logo-community.png">
          <div class="logo-title">
            江津统一门户平台
          </div>
          <div class="logo-title-en">
            PORTAL PLATFORN
          </div>
        </div>
        <div class="login-form-block clearfix">
          <div class="tabs">
            <a :class="!isShow ? 'active':''" @click="isShow=false">账号登录</a>
            <a :class="isShow ? 'active':''" @click="isShow=true">Ukey登录 </a>
          </div>
          <!-- 普通登录 -->
          <div v-if="!isShow">
            <el-form ref="loginForm" class="form" :model="loginForm" inline>
              <el-form-item prop="username">
                <el-input ref="userName" v-model="loginForm.username" class="login-form-input" placeholder="请输入用户名"
                  placeholder-class="login-form-input__placeholder" @keyup.native.enter="login">
                  <img slot="prefix" src="images/sign_ic_user.png">
                </el-input>
              </el-form-item>
              <el-form-item prop="password">
                <el-input v-model="loginForm.password" type="password" class="login-form-input" placeholder="请输入用户密码"
                  placeholder-class="login-form-input__placeholder" @keyup.native.enter="login">
                  <img slot="prefix" src="images/sign_suo.png">
                </el-input>
              </el-form-item>
              <el-form-item class="verification-code" prop="verification">
                <el-input v-model="loginForm.verification" class="login-form-code login-form-input" placeholder="请输入验证码"
                  placeholder-class="login-form-input__placeholder" @keyup.native.enter="login">
                  <img slot="prefix" src="images/sign_yzm.png">
                </el-input>
                <div class="code-box">
                  <img :src="codeUrl" class="code-image" @click="getVerification">
                </div>
              </el-form-item>
            </el-form>
            <div class="login-btn-block">
              <div class="login-btn-new" @click="login()">
                <span class="login-btn-txt">
                  <!-- <i
                          class="el-icon-loading"
                        /> -->
                  登录
                </span>
              </div>
            </div>
          </div>
          <!-- Ukey登录 -->
          <div v-else class="form">
            <el-form ref="loginForm" class="form" :model="loginForm" inline>
              <el-form-item prop="username">
                <el-input ref="userName" v-model="loginForm.username" class="login-form-input" :value="certSN"
                  placeholder="请选择证书" placeholder-class="login-form-input__placeholder" @keyup.native.enter="userLogin">
                  <img slot="prefix" src="images/sign_ic_user.png">
                </el-input>
                <span class="select-button" @click="openCertDialog">选择证书</span>
              </el-form-item>
              <el-form-item prop="password">
                <el-input v-model="certPassword" type="password" class="login-form-input" placeholder="请输入用户密码"
                  placeholder-class="login-form-input__placeholder" @keyup.native.enter="userLogin">
                  <img slot="prefix" src="images/sign_suo.png">
                </el-input>
                <input type="hidden" name="execution" value="${flowExecutionKey}">
              </el-form-item>
            </el-form>
            <div class="login-btn-block">
              <a class="login-btn-text" @click="handleOpenUtils">
                控件下载
              </a>
            </div>
            <div class="login-btn-block">
              <div class="login-btn-new" @click="loginUkey()">
                <!-- <i
                          class="el-icon-loading"
                        /> -->
                登录
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="bottom">
        技术支持：<span class="red-bold">ROPEOK</span>罗普特科技集团股份有限公司
        <p>
          为了您更好的体验，建议使用谷歌、火狐、IE9以上版本的浏览器，分辨率设为1920*1080
        </p>
      </div>
      <!-- 证书列表 -->
      <el-dialog class="rk-dialog" :close-on-click-modal="false" :close-on-press-escape="false" title="选择证书"
        :visible="dialogVisible" width="80%" @close="handleClose">
        <div class="table">
          <el-table ref="table" :data="dialogData" stripe style="width: 100%" header-row-class-name="header-row-class">
            <el-table-column prop="certDN" label="证书DN" />
            <el-table-column prop="issuerDN" label="证书签发者" width="100" />
            <el-table-column prop="certSN" label="证书序列号" width="120" />
            <el-table-column prop="validBegin" label="有效期开始时间" width="200" />
            <el-table-column prop="validEnd" label="有效期结束时间" width="200" />
            <el-table-column prop="KeyUsage" label="密钥用法" width="100" />
            <el-table-column prop="CertType" label="证书类型" width="80" />
            <el-table-column label="操作" width="80">
              <template #default="{$index}">
                <el-button type="text" @click="handleSelectCert($index)">
                  选择证书
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-dialog>
      <!-- 选择证书 -->
      <el-dialog class="rk-dialog" :close-on-click-modal="false" :close-on-press-escape="false" title="选择证书"
        :visible.sync="dialogUtilsVisible" width="40%">
        <div class="table">
          <el-table ref="table" :data="dialogUtilsData" stripe style="width: 100%"
            header-row-class-name="header-row-class">
            <el-table-column prop="name" label="控件名称" width="200" />
            <el-table-column prop="remark" label="控件描述" show-overflow-tooltip />
            <el-table-column label="操作" width="150">
              <template #default="{row}">
                <span class="download-button" @click="handleDownload(row.path)">
                  点击下载
                </span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-dialog>
    </div>
  </div>
  <script type="text/javascript">
    // 配置对象 options
    const vm = new Vue({
      // 配置选项(option)
      // element: 指定用vue来管理页面中的哪个标签区域
      el: '#app',
      data() {
        return {
          codeUrl: '',
          captchaKey: '',
          // ukey登录
          certIndex: -1,
          certSN: '',
          certPassword: '',

          dialogData: [],
          dialogVisible: false,
          loginForm: {
            username: '',
            password: '',
            verification: ''
          },
          dialogUtilsData: [
            {
              name: 'UkeyClient',
              remark: 'Ukey客户端',
              path: 'UkeyClient.exe'
            },
            {
              name: 'UkeyBrowserPlugin.exe',
              remark: 'Ukey文件插件',
              path: 'UkeyBrowserPlugin.exe'
            },
          ],
          dialogUtilsVisible: false,

          agent: null,
          randomCode: null,
          isShow: false
        };
      },
      created() {
        this.getRandomCode()
        this.getVerification()
      },
      beforeDestroy() {
      },
      methods: {
        getVerification() {
          axios({
            method: 'get',
            url: '/image-captcha'
          }).then((res) => {
            if (res?.data?.success) {
              this.codeUrl = res?.data?.data?.codeUrl;
              this.captchaKey = res?.data?.data?.key;
            }
          });
        },
        // 账号密码登录
        login() {
          if (!this.loginForm.username || !this.loginForm.password) {
            this.$message.warning('请填写账号密码');
            return;
          }

          const form = document.createElement('form');
          form.id = 'form';
          form.method = 'post';
          form.action = '/cas/login';
          form.style.display = 'none';

          const username = document.createElement('input');
          username.name = 'username';
          username.value = this.loginForm.username;
          form.appendChild(username);

          const password = document.createElement('input');
          password.name = 'password';
          password.value = this.loginForm.password;
          form.appendChild(password);

          const verification = document.createElement('input');
          verification.name = 'captcha';
          verification.value = this.loginForm.verification;
          form.appendChild(verification);

          const loginType = document.createElement('input');
          loginType.name = 'loginType';
          loginType.value = 'username';
          form.appendChild(loginType);

          const execution = document.createElement('input');
          execution.name = 'execution';
          execution.value = '${flowExecutionKey}';
          form.appendChild(execution);

          const submit = document.createElement('input');
          submit.name = 'submit';
          submit.value = '登录';
          submit.type = 'submit';
          form.appendChild(submit);

          const _eventId = document.createElement('input');
          _eventId.name = '_eventId';
          _eventId.value = 'submit';
          form.appendChild(_eventId);

          const needCert = document.createElement('input');
          needCert.name = 'needCert';
          needCert.value = 'true';
          form.appendChild(needCert);

          document.body.appendChild(form);
          submit.click();

        },
        // 获取ukey加密随机数
        getRandomCode() {
          axios({
            method: 'get',
            url: '/cert/sign/getRandomCode'
          }).then((res) => {
            if (res.status === 200 && res.data && res.data.success) {
              this.randomCode = res.data.data;
              console.log(this.randomCode);
            }
          });
        },
        openCertDialog() {
          this.agent = new IWSAgent();
          const dllFilename = 'C:/\Windows/\sysWOW64/\SKFAPI20529.dll';
          this.agent.IWSASkfGetCertList(dllFilename, this.handleUkeyList);
        },
        // 获取证书列表
        handleUkeyList(list) {
          if (list[0] !== undefined) {
            if (list[0].errorCode !== undefined) {
              this.$message.error('证书数量为空!    错误码 ： ' + list[0].errorCode);
              return;
            }
          }
          this.dialogData = list || [];
          this.dialogVisible = true;
        },
        // 关闭弹窗
        handleClose() {
          this.dialogVisible = false;
          this.dialogData = [];
        },
        // 点击ukey登录
        loginUkey() {
          if (this.certIndex < 0) {
            this.$message.warning('请选择证书');
            return;
          }
          if (!this.certPassword) {
            this.$message.warning('请输入密码');
            return;
          }
          const UsbKeyPin = this.certPassword; // Pin码
          const CertIndex = this.certIndex; // 第几个证书
          const PlainText = this.randomCode; // 加密的内容
          const DigestArithmetic = 'SM3'; // 摘要算法
          this.agent.IWSASkfSignData(PlainText, CertIndex, UsbKeyPin, DigestArithmetic, this.handleSign);
        },
        // 选中证书
        handleSelectCert(index) {
          this.certIndex = index;
          this.certSN = this.dialogData[index].certSN;
          this.handleClose();
        },
        // ukey登录
        handleSign(errorCode, signedData) {
          if (errorCode !== '0') {
            this.$message.error('签名失败，错误码 ： ' + errorCode);
          } else {

            const form = document.createElement('form');
            form.id = 'form';
            form.method = 'post';
            form.action = '/cas/login';
            form.style.display = 'none';

            const signedInput = document.createElement('input');
            signedInput.name = 'signedText';
            signedInput.value = signedData;
            form.appendChild(signedInput);

            const needCert = document.createElement('input');
            needCert.name = 'needCert';
            needCert.value = 'true';
            form.appendChild(needCert);

            const loginType = document.createElement('input');
            loginType.name = 'loginType';
            loginType.value = 'ukey';
            form.appendChild(loginType);

            const execution = document.createElement('input');
            execution.name = 'execution';
            execution.value = '${flowExecutionKey}';
            form.appendChild(execution);

            const submit = document.createElement('input');
            submit.name = 'submit';
            submit.value = '登录';
            submit.type = 'submit';
            form.appendChild(submit);

            const _eventId = document.createElement('input');
            _eventId.name = '_eventId';
            _eventId.value = 'submit';
            form.appendChild(_eventId);

            document.body.appendChild(form);
            submit.click();
          }
        },
        // 打开控件列表
        handleOpenUtils() {
          this.dialogUtilsVisible = true;
        },
        // 下载插件
        handleDownload(path) {
          window.open(path);
        }
      }
    });
  </script>
</body>

</html>