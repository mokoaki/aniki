var FileObjects = Backbone.Collection.extend({
    model: FileObject,

    comparator: function(a, b) {
        if (a.get("object_mode") == b.get("object_mode")) {
            return (a.get("name") < b.get("name")) ? -1 : 1;
        }
        else {
            return (a.get("object_mode") < b.get("object_mode")) ? -1 : 1;
        }
    }
});
