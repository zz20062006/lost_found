/**
 * 校园失物招领平台 公共JS
 */

// 显示提示消息
function showToast(msg, type) {
    type = type || 'success';
    var bgColor = type === 'success' ? '#28a745' : (type === 'error' ? '#dc3545' : '#ffc107');
    var icon = type === 'success' ? '✓' : (type === 'error' ? '✕' : '⚠');
    var html = '<div class="toast-item" style="background:'+bgColor+';color:#fff;padding:12px 20px;border-radius:6px;margin-bottom:8px;box-shadow:0 2px 12px rgba(0,0,0,0.2);animation:slideIn 0.3s ease;">';
    html += '<span style="margin-right:8px;font-weight:bold;">'+icon+'</span>' + msg + '</div>';
    $('.toast-container').append(html);
    setTimeout(function() {
        $('.toast-item').first().fadeOut(300, function(){ $(this).remove(); });
    }, 3000);
}

// AJAX 封装
function ajaxPost(url, data, callback, isFormData) {
    var options = {
        url: url,
        type: 'POST',
        dataType: 'json',
        success: function(res) {
            if (callback) callback(res);
        },
        error: function() {
            showToast('请求失败，请检查网络连接', 'error');
        }
    };
    if (isFormData) {
        options.data = data;
        options.processData = false;
        options.contentType = false;
    } else {
        options.data = data;
    }
    $.ajax(options);
}

// 确认对话框
function confirmAction(msg, callback) {
    if (confirm(msg)) {
        callback();
    }
}

// 获取URL参数
function getUrlParam(name) {
    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
    var r = window.location.search.substr(1).match(reg);
    if (r != null) return decodeURIComponent(r[2]);
    return null;
}

// 格式化日期
function formatDate(dateStr) {
    if (!dateStr) return '';
    var d = new Date(dateStr);
    var y = d.getFullYear();
    var m = ('0'+(d.getMonth()+1)).slice(-2);
    var day = ('0'+d.getDate()).slice(-2);
    var h = ('0'+d.getHours()).slice(-2);
    var min = ('0'+d.getMinutes()).slice(-2);
    return y + '-' + m + '-' + day + ' ' + h + ':' + min;
}

// 全局搜索
$(function(){
    $('#globalSearch').on('keypress', function(e){
        if (e.which === 13) {
            var keyword = $(this).val().trim();
            if (keyword) {
                window.location.href = contextPath + '/search.jsp?keyword=' + encodeURIComponent(keyword);
            }
        }
    });

    // 图片上传预览
    $(document).on('change', '.image-upload', function(e){
        var file = e.target.files[0];
        if (file) {
            var reader = new FileReader();
            reader.onload = function(evt) {
                $(e.target).siblings('.image-preview').attr('src', evt.target.result).show();
            };
            reader.readAsDataURL(file);
        }
    });
});
