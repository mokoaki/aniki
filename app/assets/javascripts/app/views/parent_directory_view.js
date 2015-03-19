var ParentDirectoryView = Backbone.View.extend({
    tagName: "div",
    className: "parentDirectory",
    template: Handlebars.compile($("#parentDirectoriesTemplate").html()),

    events: {
        "click a.directory_item" : "clickDirectory",
    },

    clickDirectory: function() {
        event.preventDefault();
        event.stopPropagation();
        Backbone.history.navigate(this.model.get("id"), true);
    },

    render: function() {
        var template = this.template(this.model.toJSON());
        this.$el.html(template);
        return this;
    }
});
