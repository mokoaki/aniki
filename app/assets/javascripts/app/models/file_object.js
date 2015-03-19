var FileObject = Backbone.Model.extend({
    urlRoot: "/file_objects/",

    parse: function(result) {
        result.id = result.id_hash;
        delete result.id_hash;
        return result;
    },
});
