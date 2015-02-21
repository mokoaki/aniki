var MenuView = Backbone.View.extend({
    el: "#menu",

    events: {
        "click button#createDirectoryButton" : "clickCreateDirectoryButton",
        "click button#cutObjectButton"       : "clickCutObjectButton",
        "click button#pasteObjectButton"     : "clickPasteObjectButton",
        "click button#deleteObjectButton"    : "clickDeleteObjectButton",
        "click button#userEditButton"        : "clickUserEditButton",
        "click button#userCreateButton"      : "clickUserCreateButton",
        "keydown input#newDirectoryName"     : "keydownNewDirectoryName"
    },

    clickCreateDirectoryButton: function() {
        var fileObject = new FileObject();
        var that = this;

        fileObject.save(
            {
                name: $("#newDirectoryName").val(),
                parent_directory_id_hash: setting.currentDirectoryIdHash,
                object_mode: 3
            },
            {
                success: function(model, response, options) {
                    $("#newDirectoryName").val("");

                    fileObjects.add(model);
                    fileObjectsView.render();
                },
                error: function(model, response, options) {
                    console.log("error");
                }
            }
        );
    },

    keydownNewDirectoryName: function(event) {
        if (event.which === 13) {
            this.clickCreateDirectoryButton();
        }
    },

    clickCutObjectButton: function() {
        setting.cutFileObjects = fileObjects.where({checked: true});

        _.each(setting.cutFileObjects, function(cutFileObject) {
            cutFileObject.trigger("cuted");
        });

        menuView.resetMenuButton();
    },

    clickPasteObjectButton: function() {
        if (setting.cutFileObjects.length === 0) {
            return true;
        }

        setting.cutFileObjects.forEach(function(pasteFileObject) {
            pasteFileObject.save(
                {
                    parent_directory_id_hash: setting.currentDirectoryIdHash
                },
                {
                    success: function(model, response, options) {
                        pasteFileObject.set({checked: false});
                        fileObjects.add(pasteFileObject);
                        fileObjectsView.render();
                    },
                    error: function(model, response, options) {
                        console.log("error");
                    }
                }
            );
        });

        setting.cutFileObjects = [];
    },

    clickDeleteObjectButton: function() {
        fileObjects.where({checked: true}).forEach(function(fileObject) {
            // サーバサイドの処理が失敗しても画面からは消すらしい。いいのそれで？
            fileObject.destroy();
        });
    },

    clickUserEditButton: function() {
        window.location = "/users";
    },

    clickUserCreateButton: function() {
        window.location = "/users/new";
    },

    resetMenuButton: function() {
        var flg = fileObjects.where({checked: true}).length > 0;

        $("button#cutObjectButton").prop("disabled", !flg);
        $("button#pasteObjectButton").prop("disabled", setting.cutFileObjects.length === 0);
        $("button#deleteObjectButton").prop("disabled", !flg);
    }
});
