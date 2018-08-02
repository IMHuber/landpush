<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<body onload="registerSw()">

<script type="text/javascript">

    function registerSw() {
        if ('serviceWorker' in navigator && 'PushManager' in window) {
            console.log('Service Worker and Push is supported');

            var swRegistration;

            return getSWRegistration()
                .then(function(swReg) {
                    console.log('Service Worker is registered', swReg);
                    swRegistration = swReg;

                    getNotificationPermissionState()
                        .then(function (result) {
                            if (result !== 'granted') {
                                askPermission();
                            }
                        });
                })
                .catch(function(error) {
                    console.error('Service Worker Error', error);
                });
        } else {
            console.warn('Push messaging is not supported');
            pushButton.textContent = 'Push Not Supported';
        }
    }

    function getNotificationPermissionState() {
        if (navigator.permissions) {
            return navigator.permissions.query({name: 'notifications'})
                .then((result) => {
                return result.state;
                });
        }
        return new Promise((resolve) => {
            resolve(Notification.permission);
        });
    }

    function askPermission() {
        if (Notification.permission === "denied") {
            alert("Notifications blocked. Please enable them in your browser.");
        }

        return new Promise(function(resolve, reject) {
            var permissionResult = Notification.requestPermission(function(result) {
                resolve(result);
            });
            if (permissionResult) {
                permissionResult.then(resolve, reject);
            }
        })
            .then(function(permissionResult) {
                if (permissionResult !== 'granted') {
                    throw new Error('We weren\'t granted permission.');
                }
                subscribe();
            });
    }


    function subscribe() {
        return getSWRegistration()
            .then(function(registration) {
                var subscribeOptions = {
                    userVisibleOnly: true,
                    applicationServerKey: urlBase64ToUint8Array(
                        'BFhHkNpDJPHyCzPpnUNufgdPaGEA7bFQ-eB4LVfSTzeDzoS-zN4pROy4y0KFelz8A-1tXmGLJevgv14ORdnYcRg'
                    )
                };
                return registration.pushManager.subscribe(subscribeOptions);
            })
            .then(function(pushSubscription) {
                var subStr = JSON.stringify(pushSubscription);
                var subJson = JSON.parse(subStr);
                subJson["sourceUrl"] = window.location.href;
                console.log('Received PushSubscription: ', subJson);

                saveSubscription(subJson)
                    .then(function (response) {
                        console.log('Subscribed successfully: ', response.data);
                    })
                    .catch(console.log("error"));

                return pushSubscription;
            });
    }

    function saveSubscription(subJson) {
        var xhr = new XMLHttpRequest();
        var url = "https://env-9888409.jelastic.regruhosting.ru/api/subscribe";
        //var url = "http://pushsend-pushgroup.193b.starter-ca-central-1.openshiftapps.com/pushapp-1.0-SNAPSHOT/api/subscribe";
        xhr.open("POST", url, true);

        xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");

        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var json = JSON.parse(xhr.responseText);
                console.log(json.email + ", " + json.password);
            }
        };
        xhr.send(JSON.stringify(subJson));
    }


    function getSWRegistration() {
        return navigator.serviceWorker.register('/sw.js');
    }

    function urlBase64ToUint8Array(base64String) {
        var padding = '='.repeat((4 - base64String.length % 4) % 4);
        var base64 = (base64String + padding)
            .replace(/\-/g, '+')
            .replace(/_/g, '/');

        var rawData = window.atob(base64);
        var outputArray = new Uint8Array(rawData.length);

        for (var i = 0; i < rawData.length; ++i) {
            outputArray[i] = rawData.charCodeAt(i);
        }
        return outputArray;
    }

</script>

<h2 style="padding-left: 29%"><============  ЖМИ, НЕ ТОРМОЗИ!</h2>
</body>
</html>
