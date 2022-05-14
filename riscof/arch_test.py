# See LICENSE.incore for details

import logging
import git
from git import InvalidGitRepositoryError
import riscof.constants as constants
logger = logging.getLogger(__name__)

def get_version(path):
    ver_dict = {
        'commit': '-',
        'version': '-'
    }
    success = False
    try:
        repo = git.Repo(path,search_parent_directories=True)
    except InvalidGitRepositoryError:
        logger.debug("Suite path is not a git repository.")
    else:
        commit = repo.head.commit
        tags = repo.tags
        remote = repo.remote()
        url = remote.url
        if (tags) and (url==constants.https_url or url == constants.ssh_url):
            ver_dict['commit'] = str(commit)
            for tag in tags:
                if tag.commit == commit:
                    ver_dict['version'] = str(tag)
            success = True
        else:
            logger.debug("Repository is not the official RISCV Architectural Test suite or the \
branch is not the main branch.")
    return ver_dict,success

def update(path,branch='main'):
    version,is_repo = get_version(path)
    if is_repo:
        logger.debug("Current version of the repository: " + version['version'])
        logger.debug("Current commit hash of the repository: " + version['commit'])
        repo = git.Repo(path)
        repo.git.pull('origin','main')
        latest_tag = (repo.tags)[-1]
        checkout_target = latest_tag if branch=='latest' else branch
        repo.git.checkout(checkout_target)
        version,_ = get_version(path)
        logger.info("Updated version of the repository: " + version['version'])
        logger.info("Updated commit hash of the repository: " + version['commit'])
    else:
        logger.info("Directory does not contain the riscv-arch-test repo.")

def clone(path,branch="main"):
    logger.info("Clonning repository at "+str(path))
    repo = git.Repo.clone_from(constants.https_url, path)
    latest_tag = (repo.tags)[-1]
    checkout_target = latest_tag if branch=='latest' else branch
    repo.git.checkout(checkout_target)
    version, _ = get_version(path)
    logger.info("Clonned version {0} of the repository with commit hash {1} ".format(
                    str(version['version']),version['commit']))

