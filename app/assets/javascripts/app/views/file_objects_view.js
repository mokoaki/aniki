var FileObjectsView = Backbone.View.extend({
    el: "#current_files_list",

    initialize: function() {
        this.collection.on("reset", this.render, this);
    },

    render: function() {
        this.$el.html("");

        this.collection.each(function(fileObject) {
            var fileObjectView = new FileObjectView({model: fileObject});
            this.$el.append(fileObjectView.render().el);
        }, this);

        menuView.resetMenuButton();

        return this;
    },
});
