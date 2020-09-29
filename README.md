# README

This project is a code test that primarily focuses on APIs. It uses standard
Rails models and migrations, but the interesting bits are mostly in app/api
and spec. It uses grape API and grape-entity for endpoints and serialization
(respectively).

A couple of novel features:

1. It uses a Paginator PORO that gets initialized with an AR relation.  That means
that it can be used to paginate any resource using 'limit' and 'offset'. The Projects
collection and the Clients collection are currently covered by their own specs.
However, it would be pretty straightforward to extract a shared_example in the next
refactor to make it truly generic.

2. It uses a concern to create a ProjectStatus 'enum' rather than the problematic
AR enum.  Many examples that I've seen using the AR enum don't pass the TRUE test.
The pattern used here enables creating a collection of constants that 'quack'
similarly to an AR model.  I've used this pattern to stub certain models that would
later be replaced by real AR models to facilitate an Agile style of development.
That way, models that are needed but not of primary concern can be represented
wile working towards an MVP.  I've also used this pattern where it was unclear
whether users would later want to define their own statuses.  It's a cheap yet clean
way to gain flexibility.

3. I stubbed an authentication/authorization system in app/api/api.rb.  Normally,
I would just create a 'current_user' method and return a hardcoded user struct.
Permissions are a natural thing to defer to a card in the backlog since the full
feature set has to be developed (and tested) first.  Adding authorization is therefore
more about taking things away. It's useful to avoid permissions errors until
the project is more defined.

4. I returned the associated client record when a client is created while creating
a project, as well as on 'Show.'  I return the full records for the admin, mainly
to show conditional exposure and how permissions work.  Something like JSON api
could be used to enable clients to request specific fields.  However, in this context
(clinical trials), there are a lot of issues with 'blinded' vs 'unblinded' fields.

5. The request specs are far from complete, but I tried to create examples that show
testing patterns for permissions and errors. My general philosophy is 'put the
duplication in to make it obvious, and then take the duplication out.' Full coverage
for Projects would thus be a matter of copy/paste, but there are natural shared
examples to be factored out.
