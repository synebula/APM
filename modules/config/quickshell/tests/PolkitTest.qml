import "../services"
import QtQuick

TestSuite {
    id: root

    name: "Polkit"

    function cleanup() {
        PolkitService.resetSimulation();
    }

    function test_initialState() {
        verify(!PolkitService.isOpen, "Polkit dialog should be closed initially");
        verify(!PolkitService.isSubmitting, "Polkit service should not be submitting initially");
    }

    function test_simulationRequestOpensAndPopulatesProperties() {
        PolkitService.simulateRequest({
            "message": "Auth required for system action",
            "actionId": "org.freedesktop.policykit.exec",
            "user": "alex",
            "inputPrompt": "Password for alex: "
        });

        verify(PolkitService.isOpen, "Dialog should be open");
        compare(PolkitService.message, "Auth required for system action");
        compare(PolkitService.actionId, "org.freedesktop.policykit.exec");
        compare(PolkitService.inputPrompt, "Password for alex: ");
        verify(PolkitService.isResponseRequired, "Response should be required");
        compare(PolkitService.identities.length, 1);
        verify(PolkitService.selectedIdentity !== null);
    }

    function test_submitCallsFlowSubmit() {
        let submittedValue = "";
        PolkitService.simulateRequest({
            "message": "Auth test",
            "onSubmit": function(value) {
                submittedValue = value;
            }
        });

        verify(PolkitService.isOpen);
        PolkitService.submit("test_pass_123");
        verify(PolkitService.isSubmitting, "Should mark isSubmitting as true");
        compare(submittedValue, "test_pass_123");
    }

    function test_errorFeedbackTrigger() {
        let errorFired = false;
        const conn = errorConnComponent.createObject(root, {
            "triggerHandler": function() {
                errorFired = true;
            }
        });

        PolkitService.simulateRequest({
            "message": "Auth test"
        });

        PolkitService.submit("bad_pass");
        verify(PolkitService.isSubmitting);

        PolkitService.updateSimulation({
            "supplementaryMessage": "Authentication failed",
            "supplementaryIsError": true
        });

        verify(errorFired, "errorTriggered signal should be emitted");
        compare(PolkitService.supplementaryMessage, "Authentication failed");
        verify(PolkitService.supplementaryIsError, "supplementaryIsError should be true");
        verify(!PolkitService.isSubmitting, "isSubmitting should be reset to false on error");

        conn.destroy();
    }

    function test_cancelClosesDialog() {
        let cancelCalled = false;
        PolkitService.simulateRequest({
            "message": "Cancel test",
            "onCancel": function() {
                cancelCalled = true;
            }
        });

        verify(PolkitService.isOpen);
        PolkitService.cancel();
        verify(cancelCalled, "onCancel should be called");
        verify(!PolkitService.isOpen, "Dialog should be closed after cancel");
        verify(!PolkitService.isSubmitting);
    }

    function test_multipleIdentitiesSelection() {
        PolkitService.simulateRequest({
            "message": "Multi-user test",
            "identities": [
                { "displayName": "Alex", "string": "unix-user:alex", "isGroup": false },
                { "displayName": "root", "string": "unix-user:root", "isGroup": false }
            ]
        });

        compare(PolkitService.identities.length, 2);
        compare(PolkitService.selectedIdentity.string, "unix-user:alex");

        PolkitService.selectIdentity(PolkitService.identities[1]);
        compare(PolkitService.selectedIdentity.string, "unix-user:root");
    }

    function test_flowRequestNestedFallback() {
        PolkitService.simulateRequest({
            "message": "",
            "actionId": ""
        });
        PolkitService.updateSimulation({
            "message": "",
            "actionId": "",
            "iconName": "",
            "request": {
                "message": "Nested request message",
                "actionId": "org.quickshell.nested.exec",
                "iconName": "nested-icon"
            }
        });

        compare(PolkitService.message, "Nested request message");
        compare(PolkitService.actionId, "org.quickshell.nested.exec");
        compare(PolkitService.iconName, "nested-icon");
    }

    Component {
        id: errorConnComponent

        Connections {
            property var triggerHandler: null
            target: PolkitService
            function onErrorTriggered() {
                if (typeof triggerHandler === "function")
                    triggerHandler();
            }
        }
    }
}
