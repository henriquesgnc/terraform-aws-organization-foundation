# Contributing

Thanks for your interest in contributing to this project. Here's how to get started.

## Setup

1. Fork the repository
2. Clone your fork
3. Run `terraform fmt -recursive` to ensure consistent formatting

## Making Changes

1. Create a branch from `main`
2. Make your changes
3. Run `terraform fmt -check -recursive && terraform validate` on any stack you modified
4. Update documentation if your change affects user-facing behavior
5. Commit using [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):
   ```
   feat(vpc): add Transit Gateway attachment option
   fix(scp): correct DenyPublicS3Buckets condition
   chore(deps): bump AWS provider to 5.x
   ```

## Pull Request Guidelines

- Keep PRs focused on a single change
- Reference any issues your PR addresses
- Include the plan output (or a summary) for Terraform changes
- Add or update tests when applicable

## Code Style

- `terraform fmt -recursive` is mandatory
- Use snake_case for resource and variable names
- Keep line length under 120 characters
- Avoid hardcoded values — use `locals` or `variables` with sensible defaults

## Modules

When adding or changing a module:
- Document all input variables with `description`
- Add `output.tf` for any values meant to be consumed by parent stacks
- Keep modules self-contained and reusable

## Stacks

Each stack under `aws/organizations/` follows this structure:
```
<stack>/
├── backend.tf      # S3 backend + required providers
├── provider.tf     # AWS provider(s) with assume_role
├── vars.tf         # Locals (project name, account, region)
├── data.tf         # SSM parameter lookups and locals
└── *.tf            # Resources and module calls
```

## Questions?

Open a [discussion](https://github.com/henriquesgnc/terraform-aws-organization-foundation/discussions) or an issue.
