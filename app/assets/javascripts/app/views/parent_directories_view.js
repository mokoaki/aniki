var ParentDirectoriesView = Backbone.View.extend({
    el: "#parent_directories_list",

    initialize: function() {
        this.collection.on("reset", this.render, this);
    },

    render: function() {
        this.$el.html("");
        var marginCount = 0;

        this.collection.each(function(parentDirectory) {
            parentDirectory.set({margin: marginCount})
            marginCount += 20;
            var parentDirectoryView = new ParentDirectoryView({model: parentDirectory});
            this.$el.append(parentDirectoryView.render().el);
        }, this);

        return this;
      }
});
