var pushEnabled = false;
var app = {

    initialize: function() {
        document.addEventListener(
            'deviceready', this.onDeviceReady.bind(this), false);
    },

    onDeviceReady: function() {
        document.getElementById('fetchTokenBtn')
            .addEventListener('click', app.fetchSystemToken);
        document.getElementById('fetchDeviceIdBtn')
            .addEventListener('click', app.fetchDeviceId);
        document.getElementById('togglePushBtn')
            .addEventListener('click', app.togglePush);
        document.getElementById('setContactKey')
            .addEventListener('click', app.contactKeySubmit);
        MCCordovaPlugin.isPushEnabled(app.handlePushState);
        MCCordovaPlugin.getContactKey(app.handleContactKey);
        MCCordovaPlugin.getTags(app.handleTags);
        MCCordovaPlugin.getAttributes(app.handleAttributes);
        document.getElementById('addAttr').addEventListener(
            'click', app.addAttribute);
        document.getElementById('clearAttr')
            .addEventListener('click', app.clearAttribute);
        document.getElementById('addTag').addEventListener('click', app.addTag);
        document.getElementById('removeTag')
            .addEventListener('click', app.removeTag);
        document.getElementById('enableLogging')
            .addEventListener('click', app.enableLogging);
        document.getElementById('disableLogging')
            .addEventListener('click', app.disableLogging);
        document.getElementById('logSdkState')
            .addEventListener('click', app.logSdkState);
        document.getElementById('track').addEventListener('click', app.track);
        MCCordovaPlugin.setOnNotificationOpenedListener(app.notificationOpened);
        MCCordovaPlugin.setOnUrlActionListener(app.urlActionListener);
        document.getElementById('analyticsToggle')
            .addEventListener('change', app.updateAnalyticsState);
        document.getElementById('piAnalyticsToggle')
            .addEventListener('change', app.updatePiAnalyticsState);
        MCCordovaPlugin.isAnalyticsEnabled(function(enabled) {
            console.log('isAnalyticsEnabled: ' + enabled);
            document.getElementById('analyticsToggle').checked = enabled;
        });
        MCCordovaPlugin.isPiAnalyticsEnabled(function(enabled) {
            console.log('isAnalyticsEnabled: ' + enabled);
            document.getElementById('piAnalyticsToggle').checked = enabled;
        });
    },
    fetchSystemToken: function() {
        MCCordovaPlugin.getSystemToken(function(token) {
            document.getElementById('pushToken').textContent = token;
            var b = document.getElementById('fetchTokenBtn');
            b.parentNode.removeChild(b);
        });
    },
    fetchDeviceId: function() {
        MCCordovaPlugin.getDeviceId(function(deviceId) {
            document.getElementById('deviceId').textContent = deviceId;
            var b = document.getElementById('fetchDeviceIdBtn');
            b.parentNode.removeChild(b);
        });
    },
    handlePushState: function(enabled) {
        var toggle = document.getElementById('togglePushBtn');
        if (enabled) {
            toggle.textContent = 'Disable Push';
        } else {
            toggle.textContent = 'Enable Push';
        }
        pushEnabled = enabled;
    },
    togglePush: function() {
        if (pushEnabled) {
            MCCordovaPlugin.disablePush();
        } else {
            MCCordovaPlugin.enablePush();
        }
        MCCordovaPlugin.isPushEnabled(app.handlePushState);
    },
    handleContactKey: function(key) {
        document.getElementById('contactKey').value = key;
    },
    contactKeySubmit: function() {
        MCCordovaPlugin.setContactKey(
            document.getElementById('contactKey').value);
    },
    handleTags: function(tags) {
        document.getElementById('tags').innerHTML =
            JSON.stringify(tags, undefined, 2);
    },
    handleAttributes: function(attributes) {
        document.getElementById('attributes').innerHTML =
            JSON.stringify(attributes, undefined, 2);
    },
    addAttribute: function() {
        var key = document.getElementById('attrKey').value;
        var value = document.getElementById('attrValue').value;

        if (!key || key === '') {
            alert('Key cannot be null or empty.');
            return;
        }
        if (!value || value === '') {
            alert('Value cannot be null or empty.');
            return;
        }

        MCCordovaPlugin.setAttribute(
            key, value,
            function() {
                MCCordovaPlugin.getAttributes(app.handleAttributes);
            },
            function(msg) {
                alert(msg);
            });
    },
    clearAttribute: function() {
        var key = document.getElementById('attrKey').value;
        if (!key || key === '') {
            alert('Key cannot be null or empty.');
            return;
        }
        MCCordovaPlugin.clearAttribute(key, function() {
            MCCordovaPlugin.getAttributes(app.handleAttributes);
        });
    },
    addTag: function() {
        var tag = document.getElementById('tag').value;
        if (!tag || tag === '') {
            alert('Tag cannot be null or empty.');
            return;
        }
        MCCordovaPlugin.addTag(tag, function() {
            MCCordovaPlugin.getTags(app.handleTags);
        });
    },
    removeTag: function() {
        var tag = document.getElementById('tag').value;
        if (!tag || tag === '') {
            alert('Tag cannot be null or empty.');
            return;
        }
        MCCordovaPlugin.removeTag(tag, function() {
            MCCordovaPlugin.getTags(app.handleTags);
        });
    },
    enableLogging: function() {
        MCCordovaPlugin.enableLogging();
    },
    disableLogging: function() {
        MCCordovaPlugin.disableLogging();
    },
    logSdkState: function() {
        MCCordovaPlugin.logSdkState();
        navigator.notification.alert('Check device logs for output.');
    },
    notificationOpened: function(value) {
        var jsonString = JSON.stringify(value, null, 4);
        document.getElementById('notificationData').textContent = jsonString;
        var url = JSON.parse(jsonString).values.url;
        if (url) {
            window.open(url, '_blank');
        }
    },
    urlActionListener: function(value) {
        var jsonString = JSON.stringify(value, null, 4);
        document.getElementById('urlActionData').textContent = jsonString;
        var url = JSON.parse(jsonString).url;
        if (url) {
            window.open(url, '_blank');
        }
    },
    track: function() {
        var event = new SFMCEvent.CustomEvent('screenViewed', {screenName: 'HomeScreen'});
        MCCordovaPlugin.track(event);    
    },
    updateAnalyticsState: function() {
        var isEnabled = document.getElementById('analyticsToggle').checked;
        MCCordovaPlugin.setAnalyticsEnabled(isEnabled);
        MCCordovaPlugin.isAnalyticsEnabled(function(enabled) {
            document.getElementById('analyticsToggle').checked = enabled;
        });
    },
    updatePiAnalyticsState: function() {
        var isEnabled = document.getElementById('piAnalyticsToggle').checked;
        MCCordovaPlugin.setPiAnalyticsEnabled(isEnabled);
        MCCordovaPlugin.isPiAnalyticsEnabled(function(enabled) {
            document.getElementById('piAnalyticsToggle').checked = enabled;
        });
    },
};

app.initialize();
