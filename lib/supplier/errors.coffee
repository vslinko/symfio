#### Supplier exit codes.
module.exports.UPLOAD_DIRECTORY_IS_NOT_PUBLIC =
    code: 1, error: "Uploads directory isn't in public directory"

module.exports.COMMAND_PROJECT_NAME_NOT_CORRECT =
    code: 1, error: "Project name not correct"

module.exports.COMMAND_DESTINATION_EXISTS =
    code: 2, error: "Destination exist, aborting."

module.exports.COMMAND_NPM_LOAD_ERROR =
    code: 3, error: "Npm load error"

module.exports.COMMAND_GIT_NOT_INSTALLED =
    code: 4, error: "Git not installed"

module.exports.COMMAND_GIT_INIT_REPOSITORY_ERROR =
    code: 5, error: "Git init repository error"

module.exports.COMMAND_GIT_COMMIT_ERROR =
    code: 6, error: "Git commit project error"
