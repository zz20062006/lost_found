<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lostfound.entity.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser != null) {
        response.sendRedirect("index.jsp");
        return;
    }
    String mode = request.getParameter("mode");
    boolean isRegister = "register".equals(mode);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isRegister ? "注册" : "登录" %> - 校园失物招领</title>
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="css/style.css">
    <style>
        :root {
            --primary: #667eea;
            --primary-dark: #5a6fd6;
            --bg: #f0f2ff;
            --card-bg: #ffffff;
            --text: #3a3d5c;
            --text-light: #7b7ea0;
            --character-skin: #ffe4c4;
            --character-hair: #4a3728;
            --character-shirt: #667eea;
            --character-eye: #2c3e50;
            --character-blush: #ffb6c1;
            --character-mouth: #ff6b6b;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #e8ebff 0%, #fce4ec 30%, #f3e5f5 60%, #e0f2f1 100%);
            background-size: 400% 400%;
            animation: gradientShift 15s ease infinite;
            font-family: 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow-x: hidden;
        }

        @keyframes gradientShift {
            0%   { background-position: 0% 50%; }
            25%  { background-position: 50% 0%; }
            50%  { background-position: 100% 50%; }
            75%  { background-position: 50% 100%; }
            100% { background-position: 0% 50%; }
        }

        /* Floating bubbles */
        .bubbles { position: fixed; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; z-index: 0; }
        .bubble {
            position: absolute;
            border-radius: 50%;
            background: rgba(255,255,255,0.3);
            animation: floatUp linear infinite;
        }
        @keyframes floatUp {
            0% { transform: translateY(100vh) scale(0); opacity: 0; }
            10% { opacity: 1; }
            90% { opacity: 1; }
            100% { transform: translateY(-10vh) scale(1); opacity: 0; }
        }

        /* Main container */
        .auth-wrapper {
            position: relative;
            z-index: 1;
            display: flex;
            background: var(--card-bg);
            border-radius: 28px;
            box-shadow: 0 25px 80px rgba(102,126,234,0.15), 0 10px 30px rgba(0,0,0,0.08);
            overflow: hidden;
            max-width: 920px;
            width: 95%;
            min-height: 580px;
            transition: min-height 0.5s ease;
        }
        .auth-wrapper.register-mode { min-height: 660px; }

        /* Character panel (left) */
        .character-panel {
            width: 42%;
            background: linear-gradient(180deg, #eef0ff 0%, #f8f9ff 100%);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
            padding: 30px 20px;
        }
        .character-panel::before {
            content: '';
            position: absolute;
            width: 250px; height: 250px;
            background: rgba(102,126,234,0.06);
            border-radius: 50%;
            top: -60px; right: -80px;
        }
        .character-panel::after {
            content: '';
            position: absolute;
            width: 180px; height: 180px;
            background: rgba(252,228,236,0.3);
            border-radius: 50%;
            bottom: -40px; left: -50px;
        }

        /* CSS Character */
        .character {
            position: relative;
            width: 180px;
            height: 200px;
            z-index: 2;
            animation: characterFloat 3s ease-in-out infinite;
        }
        @keyframes characterFloat {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-8px); }
        }

        /* Head */
        .char-head {
            width: 90px; height: 100px;
            background: var(--character-skin);
            border-radius: 50% 50% 45% 45%;
            position: absolute;
            top: 10px; left: 50%;
            transform: translateX(-50%);
            z-index: 5;
            transition: transform 0.2s;
        }

        /* Hair */
        .char-hair {
            position: absolute;
            width: 100px; height: 60px;
            background: var(--character-hair);
            border-radius: 50% 50% 0 0;
            top: -5px; left: 50%;
            transform: translateX(-50%);
            z-index: 6;
        }
        .char-hair::after {
            content: '';
            position: absolute;
            width: 25px; height: 30px;
            background: var(--character-hair);
            border-radius: 0 50% 50% 0;
            top: 20px; left: -18px;
        }

        /* Eyes container */
        .char-eyes {
            position: absolute;
            top: 38px; left: 50%;
            transform: translateX(-50%);
            width: 50px;
            display: flex;
            justify-content: space-between;
            z-index: 8;
        }
        .char-eye {
            width: 18px; height: 20px;
            background: white;
            border-radius: 50%;
            position: relative;
            overflow: hidden;
            border: 2px solid var(--character-eye);
            transition: height 0.15s;
        }
        .char-eye .pupil {
            width: 8px; height: 9px;
            background: var(--character-eye);
            border-radius: 50%;
            position: absolute;
            top: 50%; left: 50%;
            transform: translate(-50%, -50%);
            transition: transform 0.08s;
        }
        .char-eye .pupil::after {
            content: '';
            width: 3px; height: 3px;
            background: white;
            border-radius: 50%;
            position: absolute;
            top: 1px; left: 1px;
        }

        /* Blush */
        .char-blush-left, .char-blush-right {
            position: absolute;
            width: 16px; height: 10px;
            background: var(--character-blush);
            border-radius: 50%;
            z-index: 4;
            opacity: 0.6;
            top: 53px;
        }
        .char-blush-left { left: 30px; }
        .char-blush-right { right: 30px; }

        /* Mouth */
        .char-mouth {
            position: absolute;
            top: 60px; left: 50%;
            transform: translateX(-50%);
            width: 16px; height: 8px;
            border-bottom: 3px solid var(--character-mouth);
            border-radius: 0 0 50% 50%;
            z-index: 8;
            transition: all 0.3s;
        }
        .char-mouth.surprised {
            width: 18px; height: 18px;
            border: 3px solid var(--character-mouth);
            border-radius: 50%;
        }
        .char-mouth.happy {
            width: 22px; height: 12px;
            border-bottom: 3px solid var(--character-mouth);
            border-radius: 0 0 60% 60%;
            top: 56px;
        }

        /* Body */
        .char-body {
            width: 70px; height: 70px;
            background: var(--character-shirt);
            border-radius: 30px 30px 15px 15px;
            position: absolute;
            top: 95px; left: 50%;
            transform: translateX(-50%);
            z-index: 3;
        }
        .char-body::after {
            content: '';
            position: absolute;
            width: 60px; height: 8px;
            background: rgba(0,0,0,0.1);
            border-radius: 4px;
            top: 15px; left: 50%;
            transform: translateX(-50%);
        }

        /* Arms */
        .char-arm {
            position: absolute;
            width: 22px; height: 55px;
            background: var(--character-shirt);
            border-radius: 11px;
            top: 98px;
            z-index: 2;
            transform-origin: top center;
            transition: transform 0.3s;
        }
        .char-arm-left { left: 35px; transform: rotate(8deg); }
        .char-arm-right { right: 35px; transform: rotate(-8deg); }
        .char-arm.waving { animation: wave 0.6s ease-in-out 2; }

        @keyframes wave {
            0%, 100% { transform: rotate(-8deg); }
            50% { transform: rotate(-35deg) translateY(-8px); }
        }

        /* Hands */
        .char-hand {
            position: absolute;
            width: 18px; height: 18px;
            background: var(--character-skin);
            border-radius: 50%;
            bottom: -5px;
            z-index: 9;
        }
        .char-arm-left .char-hand { left: 2px; }
        .char-arm-right .char-hand { right: 2px; }

        /* Cover eyes hands */
        .char-cover-hands {
            position: absolute;
            top: 30px; left: 50%;
            transform: translateX(-50%);
            width: 70px; height: 30px;
            z-index: 10;
            opacity: 0;
            transition: opacity 0.3s;
            display: flex;
            justify-content: space-between;
        }
        .char-cover-hands.show { opacity: 1; }
        .char-cover-hand {
            width: 24px; height: 22px;
            background: var(--character-skin);
            border-radius: 50%;
            margin-top: 5px;
        }
        .char-eye.closed { height: 3px !important; }

        /* Form panel (right) */
        .form-panel {
            width: 58%;
            padding: 45px 50px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            position: relative;
            z-index: 1;
        }
        .form-panel h2 {
            font-weight: 700;
            color: var(--text);
            margin-bottom: 6px;
        }
        .form-panel .subtitle {
            color: var(--text-light);
            font-size: 0.9rem;
            margin-bottom: 28px;
        }

        /* Form styling */
        .input-group-custom {
            position: relative;
            margin-bottom: 20px;
        }
        .input-group-custom .input-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #b0b5d0;
            font-size: 1rem;
            transition: color 0.3s;
            z-index: 2;
            pointer-events: none;
        }
        .input-group-custom input {
            width: 100%;
            padding: 14px 16px 14px 46px;
            border: 2px solid #e8eaf6;
            border-radius: 14px;
            font-size: 0.95rem;
            background: #fafbff;
            color: var(--text);
            transition: all 0.3s;
            outline: none;
        }
        .input-group-custom input:focus {
            border-color: var(--primary);
            background: #fff;
            box-shadow: 0 0 0 4px rgba(102,126,234,0.08);
        }
        .input-group-custom input:focus ~ .input-icon,
        .input-group-custom input:focus + .input-icon { color: var(--primary); }
        .input-group-custom input:focus + .focus-border {
            width: 100%;
        }

        .btn-auth {
            width: 100%;
            padding: 14px;
            border: none;
            border-radius: 14px;
            font-size: 1rem;
            font-weight: 600;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: #fff;
            cursor: pointer;
            transition: all 0.3s;
            letter-spacing: 0.5px;
            position: relative;
            overflow: hidden;
        }
        .btn-auth:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102,126,234,0.4);
        }
        .btn-auth:active { transform: translateY(0); }
        .btn-auth .spinner {
            display: none;
            width: 20px; height: 20px;
            border: 2px solid rgba(255,255,255,0.3);
            border-top-color: #fff;
            border-radius: 50%;
            animation: spin 0.6s linear infinite;
            position: absolute;
            right: 20px; top: 50%;
            transform: translateY(-50%);
        }
        @keyframes spin { to { transform: translateY(-50%) rotate(360deg); } }

        .switch-link {
            text-align: center;
            margin-top: 20px;
            color: var(--text-light);
            font-size: 0.9rem;
        }
        .switch-link a {
            color: var(--primary);
            font-weight: 600;
            text-decoration: none;
            transition: color 0.3s;
        }
        .switch-link a:hover { color: var(--primary-dark); }

        /* Register mode extra fields */
        .extra-fields {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.5s ease, opacity 0.3s;
            opacity: 0;
        }
        .register-mode .extra-fields {
            max-height: 300px;
            opacity: 1;
        }

        /* Back link */
        .back-home {
            position: fixed;
            top: 20px; left: 20px;
            color: var(--text-light);
            text-decoration: none;
            font-size: 0.85rem;
            z-index: 10;
            transition: color 0.3s;
            background: rgba(255,255,255,0.8);
            padding: 8px 16px;
            border-radius: 20px;
            backdrop-filter: blur(10px);
        }
        .back-home:hover { color: var(--primary); text-decoration: none; }

        /* Responsive */
        @media (max-width: 768px) {
            .auth-wrapper { flex-direction: column; max-width: 420px; min-height: auto; }
            .character-panel { width: 100%; padding: 30px 20px 15px; }
            .character { transform: scale(0.75); }
            .form-panel { width: 100%; padding: 20px 30px 35px; }
        }

        /* Status message */
        .status-msg {
            text-align: center;
            padding: 8px;
            border-radius: 8px;
            margin-bottom: 15px;
            font-size: 0.85rem;
            display: none;
            animation: fadeInUp 0.3s ease;
        }
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .status-msg.error { background: #fff0f0; color: #e74c3c; display: block; }
        .status-msg.success { background: #f0fff4; color: #27ae60; display: block; }
    </style>
</head>
<body>

<a href="index.jsp" class="back-home"><i class="fas fa-arrow-left"></i> 返回首页</a>

<!-- Floating bubbles -->
<div class="bubbles" id="bubbles"></div>

<div class="auth-wrapper <%= isRegister ? "register-mode" : "" %>" id="authWrapper">

    <!-- Character Panel -->
    <div class="character-panel" id="characterPanel">
        <div class="character" id="character">
            <!-- Hair -->
            <div class="char-hair"></div>
            <!-- Cover hands (for password) -->
            <div class="char-cover-hands" id="coverHands">
                <div class="char-cover-hand"></div>
                <div class="char-cover-hand"></div>
            </div>
            <!-- Head -->
            <div class="char-head" id="charHead">
                <div class="char-eyes">
                    <div class="char-eye" id="leftEye"><div class="pupil"></div></div>
                    <div class="char-eye" id="rightEye"><div class="pupil"></div></div>
                </div>
                <div class="char-mouth" id="charMouth"></div>
                <div class="char-blush-left"></div>
                <div class="char-blush-right"></div>
            </div>
            <!-- Body -->
            <div class="char-body"></div>
            <!-- Arms -->
            <div class="char-arm char-arm-left" id="leftArm"><div class="char-hand"></div></div>
            <div class="char-arm char-arm-right" id="rightArm"><div class="char-hand"></div></div>
        </div>
        <p style="margin-top:15px;color:var(--primary);font-weight:600;font-size:0.95rem;z-index:2;position:relative;" id="charMessage">
            <%= isRegister ? "👋 欢迎加入我们！" : "👋 欢迎回来！" %>
        </p>
    </div>

    <!-- Form Panel -->
    <div class="form-panel" id="formPanel">
        <h2 id="formTitle"><%= isRegister ? "创建账号" : "欢迎登录" %></h2>
        <p class="subtitle" id="formSubtitle">
            <%= isRegister ? "填写信息，开始使用校园失物招领平台" : "登录你的账号，继续使用校园失物招领平台" %>
        </p>

        <div class="status-msg" id="statusMsg"></div>

        <form id="authForm" autocomplete="off">
            <!-- Username -->
            <div class="input-group-custom">
                <i class="fas fa-user input-icon"></i>
                <input type="text" name="username" id="username" placeholder="用户名" required minlength="3" autocomplete="off">
            </div>

            <!-- Password -->
            <div class="input-group-custom">
                <i class="fas fa-lock input-icon"></i>
                <input type="password" name="password" id="password" placeholder="密码" required minlength="6">
            </div>

            <!-- Extra fields for register -->
            <div class="extra-fields" id="extraFields">
                <div class="input-group-custom">
                    <i class="fas fa-id-card input-icon"></i>
                    <input type="text" name="nickname" id="nickname" placeholder="昵称（选填）">
                </div>
                <div class="input-group-custom">
                    <i class="fas fa-phone input-icon"></i>
                    <input type="text" name="phone" id="phone" placeholder="手机号（选填）">
                </div>
                <div class="input-group-custom">
                    <i class="fas fa-envelope input-icon"></i>
                    <input type="email" name="email" id="email" placeholder="邮箱（选填）">
                </div>
            </div>

            <button type="submit" class="btn-auth" id="submitBtn">
                <span class="btn-text"><%= isRegister ? "注 册" : "登 录" %></span>
                <span class="spinner"></span>
            </button>
        </form>

        <div class="switch-link" id="switchLink">
            <%= isRegister ? "已有账号？" : "还没有账号？" %>
            <a href="auth.jsp?mode=<%= isRegister ? "login" : "register" %>" id="switchBtn">
                <%= isRegister ? "立即登录" : "立即注册" %>
            </a>
        </div>
    </div>
</div>

<script src="https://cdn.bootcdn.net/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="js/common.js"></script>
<script>
    var contextPath = '${pageContext.request.contextPath}';
    var isRegister = <%= isRegister %>;

    // ========== Create floating bubbles ==========
    (function createBubbles() {
        var container = document.getElementById('bubbles');
        var colors = ['rgba(102,126,234,0.12)','rgba(252,228,236,0.15)','rgba(224,242,241,0.15)','rgba(243,229,245,0.13)'];
        for (var i = 0; i < 18; i++) {
            var bubble = document.createElement('div');
            bubble.className = 'bubble';
            var size = Math.random() * 50 + 15;
            bubble.style.width = size + 'px';
            bubble.style.height = size + 'px';
            bubble.style.left = Math.random() * 100 + '%';
            bubble.style.background = colors[Math.floor(Math.random() * colors.length)];
            bubble.style.animationDuration = (Math.random() * 15 + 10) + 's';
            bubble.style.animationDelay = (Math.random() * 10) + 's';
            container.appendChild(bubble);
        }
    })();

    // ========== Character animation: eyes follow mouse ==========
    var charHead = document.getElementById('charHead');
    var charMouth = document.getElementById('charMouth');
    var leftArm = document.getElementById('leftArm');
    var rightArm = document.getElementById('rightArm');
    var coverHands = document.getElementById('coverHands');
    var leftEye = document.getElementById('leftEye');
    var rightEye = document.getElementById('rightEye');
    var charMessage = document.getElementById('charMessage');
    var character = document.getElementById('character');

    document.addEventListener('mousemove', function(e) {
        var eyes = document.querySelectorAll('.pupil');
        var headRect = charHead.getBoundingClientRect();
        var headCenterX = headRect.left + headRect.width / 2;
        var headCenterY = headRect.top + headRect.height / 2;

        eyes.forEach(function(pupil) {
            var eyeRect = pupil.parentElement.getBoundingClientRect();
            var eyeCenterX = eyeRect.left + eyeRect.width / 2;
            var eyeCenterY = eyeRect.top + eyeRect.height / 2;
            var angle = Math.atan2(e.clientY - eyeCenterY, e.clientX - eyeCenterX);
            var distance = Math.min(Math.hypot(e.clientX - eyeCenterX, e.clientY - eyeCenterY) * 0.04, 3.5);
            var dx = Math.cos(angle) * distance;
            var dy = Math.sin(angle) * distance;
            pupil.style.transform = 'translate(calc(-50% + ' + dx + 'px), calc(-50% + ' + dy + 'px))';
        });
    });

    // ========== Character reactions to input focus ==========
    var passwordInput = document.getElementById('password');
    var usernameInput = document.getElementById('username');

    // Password focus -> character covers eyes
    passwordInput.addEventListener('focus', function() {
        coverHands.classList.add('show');
        leftEye.classList.add('closed');
        rightEye.classList.add('closed');
        charMouth.classList.add('surprised');
    });

    passwordInput.addEventListener('blur', function() {
        coverHands.classList.remove('show');
        leftEye.classList.remove('closed');
        rightEye.classList.remove('closed');
        charMouth.classList.remove('surprised');
    });

    // Username focus -> character waves
    usernameInput.addEventListener('focus', function() {
        rightArm.classList.add('waving');
        charMouth.classList.add('happy');
        charMessage.textContent = isRegister ? '😊 请输入你的用户名~' : '😊 请输入你的用户名~';
    });

    usernameInput.addEventListener('blur', function() {
        rightArm.classList.remove('waving');
        charMouth.classList.remove('happy');
        charMessage.textContent = isRegister ? '👋 欢迎加入我们！' : '👋 欢迎回来！';
    });

    // Click character -> waves
    character.addEventListener('click', function() {
        rightArm.classList.add('waving');
        setTimeout(function() { rightArm.classList.remove('waving'); }, 1200);
    });

    // ========== Form submission ==========
    $('#authForm').on('submit', function(e) {
        e.preventDefault();

        var $btn = $('#submitBtn');
        var $spinner = $btn.find('.spinner');
        var $btnText = $btn.find('.btn-text');
        var $status = $('#statusMsg');

        $btn.prop('disabled', true);
        $spinner.show();
        $btnText.text(isRegister ? '注册中...' : '登录中...');
        $status.removeClass('error success').hide();

        var data = $(this).serialize();
        data += '&action=' + (isRegister ? 'register' : 'login');

        $.post(contextPath + '/UserServlet', data, function(res) {
            if (res.code === 1) {
                // Success
                $status.addClass('success').text(res.msg).show();
                charMouth.classList.add('happy');
                rightArm.classList.add('waving');
                charMessage.textContent = '🎉 ' + res.msg;

                if (isRegister) {
                    // Switch to login after register
                    setTimeout(function() {
                        window.location.href = contextPath + '/auth.jsp?mode=login';
                    }, 1500);
                } else {
                    // Redirect to home after login
                    setTimeout(function() {
                        window.location.href = contextPath + '/index.jsp';
                    }, 800);
                }
            } else {
                // Error
                $status.addClass('error').text(res.msg).show();
                charMouth.classList.remove('happy');
                charMouth.classList.add('surprised');
                charMessage.textContent = '😥 ' + res.msg;
                setTimeout(function() {
                    charMouth.classList.remove('surprised');
                    charMessage.textContent = isRegister ? '👋 再试一次吧！' : '👋 再试一次吧！';
                }, 2000);
            }
        }, 'json').always(function() {
            $btn.prop('disabled', false);
            $spinner.hide();
            $btnText.text(isRegister ? '注 册' : '登 录');
        });
    });

    // ========== Switch between login and register ==========
    // (page reload via link, but we also update the character message)
</script>
</body>
</html>
