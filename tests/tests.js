

exports.defineAutoTests = function () {

  describe('MCCordovaPlugin structure', function () {
    it('plugin.spec.1 should exist', function () {
      expect(MCCordovaPlugin).toBeDefined();
    });

    it('plugin.spec.2 should contain a isPushEnabled function', function () {
      expect(typeof MCCordovaPlugin.isPushEnabled).toBeDefined();
      expect(typeof MCCordovaPlugin.isPushEnabled === 'function').toBe(true);
    });

    it('plugin.spec.3 should contain a enablePush function', function () {
      expect(typeof MCCordovaPlugin.enablePush).toBeDefined();
      expect(typeof MCCordovaPlugin.enablePush === 'function').toBe(true);
    });

    it('plugin.spec.4 should contain a disablePush function', function () {
      expect(typeof MCCordovaPlugin.disablePush).toBeDefined();
      expect(typeof MCCordovaPlugin.disablePush === 'function').toBe(true);
    });

    it('plugin.spec.5 should contain a getSystemToken function', function () {
      expect(typeof MCCordovaPlugin.getSystemToken).toBeDefined();
      expect(typeof MCCordovaPlugin.getSystemToken === 'function').toBe(true);
    });

    it('plugin.spec.6 should contain a getAttributes function', function () {
      expect(typeof MCCordovaPlugin.getAttributes).toBeDefined();
      expect(typeof MCCordovaPlugin.getAttributes === 'function').toBe(true);
    });

    it('plugin.spec.7 should contain a setAttribute function', function () {
      expect(typeof MCCordovaPlugin.setAttribute).toBeDefined();
      expect(typeof MCCordovaPlugin.setAttribute === 'function').toBe(true);
    });

    it('plugin.spec.8 should contain a clearAttribute function', function () {
      expect(typeof MCCordovaPlugin.clearAttribute).toBeDefined();
      expect(typeof MCCordovaPlugin.clearAttribute === 'function').toBe(true);
    });

    it('plugin.spec.9 should contain a addTag function', function () {
      expect(typeof MCCordovaPlugin.addTag).toBeDefined();
      expect(typeof MCCordovaPlugin.addTag === 'function').toBe(true);
    });

    it('plugin.spec.10 should contain a removeTag function', function () {
      expect(typeof MCCordovaPlugin.removeTag).toBeDefined();
      expect(typeof MCCordovaPlugin.removeTag === 'function').toBe(true);
    });

    it('plugin.spec.11 should contain a getTags function', function () {
      expect(typeof MCCordovaPlugin.getTags).toBeDefined();
      expect(typeof MCCordovaPlugin.getTags === 'function').toBe(true);
    });

    it('plugin.spec.12 should contain a setContactKey function', function () {
      expect(typeof MCCordovaPlugin.setContactKey).toBeDefined();
      expect(typeof MCCordovaPlugin.setContactKey === 'function').toBe(true);
    });

    it('plugin.spec.13 should contain a getContactKey function', function () {
      expect(typeof MCCordovaPlugin.getContactKey).toBeDefined();
      expect(typeof MCCordovaPlugin.getContactKey === 'function').toBe(true);
    });

    it('plugin.spec.14 should contain a enableVerboseLogging function', function () {
      expect(typeof MCCordovaPlugin.enableVerboseLogging).toBeDefined();
      expect(typeof MCCordovaPlugin.enableVerboseLogging === 'function').toBe(true);
    });

    it('plugin.spec.15 should contain a disableVerboseLogging function', function () {
      expect(typeof MCCordovaPlugin.disableVerboseLogging).toBeDefined();
      expect(typeof MCCordovaPlugin.disableVerboseLogging === 'function').toBe(true);
    });
  });
};