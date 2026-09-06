"""CLI entrypoint for learning-hog."""

from importlib.metadata import PackageNotFoundError
from importlib.metadata import version as _pkg_version
from typing import Annotated

import typer

app = typer.Typer(
    name="learning-hog",
    help="Gather free learning resources for any concept.",
    no_args_is_help=True,
)


def _get_version() -> str:
    """Return the installed package version."""
    try:
        return _pkg_version("learning-hog")
    except PackageNotFoundError:
        return "unknown"


def _version_callback(value: bool) -> None:  # ruff: ignore[boolean-type-hint-positional-argument] - signature dictated by Typer
    """Print the version and exit when --version is passed.

    Raises:
        typer.Exit: After printing the version.
    """
    if value:
        typer.echo(f"learning-hog {_get_version()}")
        raise typer.Exit


@app.callback()
def _callback(
    version: Annotated[  # ruff: ignore[boolean-default-value-positional-argument] - signature dictated by Typer
        bool,
        typer.Option(
            "--version",
            callback=_version_callback,
            is_eager=True,
            help="Show the version and exit.",
        ),
    ] = False,
) -> None:
    """Learning-hog CLI root."""
    _ = version


@app.command()
def find(
    query: Annotated[str, typer.Argument(help="Concept to find resources for.")],
) -> None:
    """Find free learning resources for QUERY (stub: adapters land in feature PRs)."""
    typer.echo(f"Searching for: {query} (stub)")


def main() -> None:
    """Console-script entry point."""
    app()


if __name__ == "__main__":
    main()
