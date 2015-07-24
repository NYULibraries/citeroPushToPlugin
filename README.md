# citeroPushToPlugin
The [Citero](https://github.com/NYULibraries/citero) push to plugin uses the [Citero web service](https://github.com/NYULibraries/ex_cite) API to route all of Primo's records to an external API endpoint. The Citero web service then resolves the action for the end user. This allows us to maintain only one application for Citation management, and guarantees all of our citations are resolved in the same way.


## Installation
### Backoffice
Once you are at the primo back office, go to the following page:

Primo Home > Advanced Configuration > All Mapping Tables > PushTo Adapters

Disable all other adapters by unchecking the __Enabled__ box. Then go to the __Create New Mapping Row__ section and add the following:

Adaptor Identifier | Key   | Value                            | Description |
-------------------|-------|----------------------------------|-------------|
RefWorks           | Class | edu.nyu.library.CitationProcess  |             |
EndNote            | Class | edu.nyu.library.CitationProcess  |             |
EasyBIB            | Class | edu.nyu.library.CitationProcess  |             |
RIS                | Class | edu.nyu.library.CitationProcess  |             |
BibTeX             | Class | edu.nyu.library.CitationProcess  |             |

### Application
To install, modify the [deploy files](https://github.com/NYULibraries/citeroPushToPlugin/tree/master/config/deploy) for your environment to properly reflect the deploy servers. We utilize [figs]() to handle the process.

Then go into the main [deploy file](https://github.com/NYULibraries/citeroPushToPlugin/blob/master/config/deploy.rb) and make sure all the locations match your primo installation, by checking to see if those paths and files exist. If not, correct the files to the right path. Also be sure to properly set your `:user`, `:javac` and `:scm_username`, replacing the `ENV` vars with the proper value (or use env vars!).

## Run

```shell
> bundle install
> bundle exec cap staging deploy
> bundle exec cap production deploy
```
