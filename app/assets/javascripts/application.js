// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require external/underscore.min
//= require external/handlebars-v3.0.0
//= require external/backbone.min
//= require external/dropzone
//= require_tree .

var fileObjects = new FileObjects([]);
var fileObjectsView = new FileObjectsView({collection: fileObjects});

var parentDirectories = new FileObjects([]);
var parentDirectoriesView = new ParentDirectoriesView({collection: parentDirectories});

var menuView = new MenuView();

var router = new Router();

var setting = {};
setting.cutFileObjects = [];
setting.currentDirectoryIdHash = "";

var myDropzone = new Dropzone("button#file_upload_field", {
    url: "file_objects",
    headers: {"X-CSRF-Token" : $("meta[name='csrf-token']").attr("content")},
    previewsContainer: false,
    // parallelUploads: 3,
    init: function () {
        this.on("sending", function(file, xhr, data) {
            data.append("parent_directory_id_hash", setting.currentDirectoryIdHash);
        });
    },
    dragenter: function() {
        $("button#file_upload_field").css("background-color", "#C4C4FF");
    },
    dragleave: function() {
        $("button#file_upload_field").css("background-color", "#c0c0c0");
    },
    drop: function() {
        $("button#file_upload_field").css("background-color", "#c0c0c0");
    },
    success: function(a, result) {
        var fileObject = new FileObject({
            id:                       result.id_hash,
            name:                     result.name,
            parent_directory_id_hash: result.parent_directory_id_hash,
            object_mode:              result.object_mode,
            size:                     result.size,
            created_at:               result.created_at,
        });

        fileObjects.add(fileObject);
        fileObjectsView.render();
    }
});



Backbone.history.start({ pushState: true });


// DOMの生成が完了してからstart()させる
// $(function () {
    // Backbone.history.start({ pushState: true });  // ブラウザのhashChangeの監視を開始する
// });
