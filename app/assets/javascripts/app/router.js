var Router = Backbone.Router.extend({
    routes: {
        ":id_hash" : "directory_change",
    },

    directory_change: function index(idHash) {
        setting.currentDirectoryIdHash = idHash;

        fileObjects.url = "http://192.168.56.11:3000/file_objects/" + idHash;
        fileObjects.fetch({ reset: true });

        parentDirectories.url = "http://192.168.56.11:3000/p/" + idHash;
        parentDirectories.fetch({ reset: true, sort: false });
    },
});
