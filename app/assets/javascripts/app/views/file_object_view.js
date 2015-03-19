var FileObjectView = Backbone.View.extend({
    tagName: "div",
    id: function() {
        return this.model.get("id");
    },
    className: "fileObject",
    template: Handlebars.compile($("#fileObjectTemplate").html()),

    initialize: function() {
        this.model.on("destroy", this.destroyModel, this);
        this.model.on("cuted", this.cutModel, this);
    },

    events: {
        "click a.directory_item"    : "clickDirectory",
        "click input.checkbox"      : "clickCheckbox",
        "click span.renameButton"   : "clickRenameButton",
        "click input.renameField"   : "clickRenameField",
        "keydown input.renameField" : "keydownRenameField",
        "click"                     : "clickView",
    },

    clickDirectory: function(event) {
        event.preventDefault();
        event.stopPropagation();
        Backbone.history.navigate(this.model.get("id"), true);
    },

    clickCheckbox: function(event) {
        event.stopPropagation();

        this.model.set({checked: event.target.checked});

        menuView.resetMenuButton();
    },

    clickRenameButton: function(event) {
        event.stopPropagation();

        this.$el.find("input.renameField").val(this.model.get("name"));
        this.$el.find("span.rename_form").show(500);
        this.$el.find("span.name_form").hide(500);
    },

    clickView: function() {
        this.$el.find("input.checkbox").click();
    },

    clickRenameField: function(event) {
        event.stopPropagation();
    },

    keydownRenameField: function(event) {
        if (event.which === 13) {
            var that = this;

            that.model.save(
                {
                    name: event.target.value
                },
                {
                    success: function(model, response, options) {
                        fileObjectsView.render();
                    }
                }
            );
        }
    },

    cutModel: function() {
        $("div#" + this.model.get("id")).addClass("cuted");
    },

    destroyModel: function() {
        this.$el.remove();
    },

    render: function() {
        var template = this.template(this.model.toJSON());
        this.$el.html(template);
        return this;
    }
});
