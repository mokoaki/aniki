var FileObject = Backbone.Model.extend({
    urlRoot: "http://192.168.56.11:3000/file_objects/",

    parse: function(result) {
        result.id = result.id_hash;
        delete result.id_hash;
        return result;
    },
});
