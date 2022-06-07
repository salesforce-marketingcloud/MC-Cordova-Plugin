/**
 * @license
 * Copyright 2018 Salesforce, Inc
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors
 * may be used to endorse or promote products derived from this software without
 * specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

exports.defineAutoTests = function() {
    describe('MCCordovaPlugin structure', function() {
        it('plugin.spec.1 should exist', function() {
            expect(MCCordovaPlugin).toBeDefined();
        });

        it('plugin.spec.2 should contain a isPushEnabled function', function() {
            expect(typeof MCCordovaPlugin.isPushEnabled).toBeDefined();
            expect(typeof MCCordovaPlugin.isPushEnabled === 'function')
                .toBe(true);
        });

        it('plugin.spec.3 should contain a enablePush function', function() {
            expect(typeof MCCordovaPlugin.enablePush).toBeDefined();
            expect(typeof MCCordovaPlugin.enablePush === 'function').toBe(true);
        });

        it('plugin.spec.4 should contain a disablePush function', function() {
            expect(typeof MCCordovaPlugin.disablePush).toBeDefined();
            expect(typeof MCCordovaPlugin.disablePush === 'function')
                .toBe(true);
        });

        it('plugin.spec.5 should contain a getSystemToken function',
           function() {
               expect(typeof MCCordovaPlugin.getSystemToken).toBeDefined();
               expect(typeof MCCordovaPlugin.getSystemToken === 'function')
                   .toBe(true);
           });

        it('plugin.spec.6 should contain a getAttributes function', function() {
            expect(typeof MCCordovaPlugin.getAttributes).toBeDefined();
            expect(typeof MCCordovaPlugin.getAttributes === 'function')
                .toBe(true);
        });

        it('plugin.spec.7 should contain a setAttribute function', function() {
            expect(typeof MCCordovaPlugin.setAttribute).toBeDefined();
            expect(typeof MCCordovaPlugin.setAttribute === 'function')
                .toBe(true);
        });

        it('plugin.spec.8 should contain a clearAttribute function',
           function() {
               expect(typeof MCCordovaPlugin.clearAttribute).toBeDefined();
               expect(typeof MCCordovaPlugin.clearAttribute === 'function')
                   .toBe(true);
           });

        it('plugin.spec.9 should contain a addTag function', function() {
            expect(typeof MCCordovaPlugin.addTag).toBeDefined();
            expect(typeof MCCordovaPlugin.addTag === 'function').toBe(true);
        });

        it('plugin.spec.10 should contain a removeTag function', function() {
            expect(typeof MCCordovaPlugin.removeTag).toBeDefined();
            expect(typeof MCCordovaPlugin.removeTag === 'function').toBe(true);
        });

        it('plugin.spec.11 should contain a getTags function', function() {
            expect(typeof MCCordovaPlugin.getTags).toBeDefined();
            expect(typeof MCCordovaPlugin.getTags === 'function').toBe(true);
        });

        it('plugin.spec.12 should contain a setContactKey function',
           function() {
               expect(typeof MCCordovaPlugin.setContactKey).toBeDefined();
               expect(typeof MCCordovaPlugin.setContactKey === 'function')
                   .toBe(true);
           });

        it('plugin.spec.13 should contain a getContactKey function',
           function() {
               expect(typeof MCCordovaPlugin.getContactKey).toBeDefined();
               expect(typeof MCCordovaPlugin.getContactKey === 'function')
                   .toBe(true);
           });

        it('plugin.spec.14 should contain a enableVerboseLogging function',
           function() {
               expect(typeof MCCordovaPlugin.enableVerboseLogging)
                   .toBeDefined();
               expect(
                   typeof MCCordovaPlugin.enableVerboseLogging === 'function')
                   .toBe(true);
           });

        it('plugin.spec.15 should contain a disableVerboseLogging function',
           function() {
               expect(typeof MCCordovaPlugin.disableVerboseLogging)
                   .toBeDefined();
               expect(
                   typeof MCCordovaPlugin.disableVerboseLogging === 'function')
                   .toBe(true);
           });

        it('plugin.spec.16 should contain a setOnPushOpenedListener function',
           function() {
               expect(typeof MCCordovaPlugin.setOnPushOpenedListener)
                   .toBeDefined();
               expect(
                   typeof MCCordovaPlugin.setOnPushOpenedListener ===
                   'function')
                   .toBe(true);
           });

        it('plugin.spec.17 should contain a track function',
           function() {
               expect(typeof MCCordovaPlugin.track)
                   .toBeDefined();
               expect(
                   typeof MCCordovaPlugin.track ==='function')
                   .toBe(true);
           });
    });
};