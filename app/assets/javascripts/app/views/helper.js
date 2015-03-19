Handlebars.registerHelper('hiduke', function(date_string) {
    return new Date(date_string).toLocaleString("ja");
});

Handlebars.registerHelper('name_henkan', function(name) {
    return (name === "root") ? name : "└ " + name;
});

Handlebars.registerHelper('isTrash', function(object_mode, options) {
    if (object_mode === 2) {
        return options.fn(this);
    }
});

Handlebars.registerHelper('isNotTrash', function(object_mode, options) {
    if (object_mode !== 2) {
        return options.fn(this);
    }
});

Handlebars.registerHelper('isDirectory', function(object_mode, options) {
    if (object_mode === 3) {
        return options.fn(this);
    }
});

Handlebars.registerHelper('isFile', function(object_mode, options) {
    if (object_mode === 4) {
        return options.fn(this);
    }
});
