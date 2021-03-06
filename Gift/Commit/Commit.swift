import Foundation
import LlamaKit

/**
  A commit object holds metadata for each change introduced into the
  repository, including the author, committer, commit date, and log message.
  Each commit points to a tree object that captures, in one complete snapshot,
  the state of the repository at the time the commit was performed.

  The initial commit, or root commit, has no parent. Most commits have one
  commit parent, although it is possible to have more than one parent.
*/
public class Commit {
  internal let cCommit: COpaquePointer

  internal init(cCommit: COpaquePointer) {
    self.cCommit = cCommit
  }

  deinit {
    git_commit_free(cCommit)
  }
}

public extension Commit {
  /**
    Returns the full message of a commit, or a failure indicating
    what went wrong when retrieving the message. The returned message
    will be slightly prettified by removing any potential leading newlines.
  */
  public var message: Result<String, NSError> {
    let cMessage = git_commit_message(cCommit)
    if let commitMessage = String.fromCString(cMessage) {
      return success(commitMessage)
    } else {
      let description = "An error occurred when attempting to convert commit message "
                        + "'\(cMessage)', provided by git_commit_message, to a String."
      return failure(NSError.giftError(.StringConversionFailure, description: description))
    }
  }

  /**
    Returns the author's signature for this commit, or a failure indicating what went
    wrong when retrieving the signature. The author of a commit is the person who authored
    the changes in the commit.
  */
  public var author: Result<Signature, NSError> {
    return Signature.fromCSignature(git_commit_author(cCommit).memory)
  }

  /**
    Returns the committer's signature for this commit, or a failure indicating what went
    wrong when retrieving the signature. The committer of a commit is the person who
    committed the code on behalf of the original author.
  */
  public var committer: Result<Signature, NSError> {
    return Signature.fromCSignature(git_commit_committer(cCommit).memory)
  }
}
