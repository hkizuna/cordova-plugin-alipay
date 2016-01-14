module.exports = {
    pay: function (payment, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "Alipay", "pay", [payment]);
    }
}