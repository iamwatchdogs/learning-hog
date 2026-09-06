from typer.testing import CliRunner

from learning_hog.main import app

runner = CliRunner()


def test_help_lists_find() -> None:
    result = runner.invoke(app, ["--help"])
    assert result.exit_code == 0
    assert "find" in result.output


def test_version_flag() -> None:
    result = runner.invoke(app, ["--version"])
    assert result.exit_code == 0
    assert "learning-hog" in result.output


def test_find_stub() -> None:
    result = runner.invoke(app, ["find", "python"])
    assert result.exit_code == 0
    assert "Searching for: python" in result.output


def test_no_args_shows_help() -> None:
    result = runner.invoke(app, [])
    assert result.exit_code != 0
    assert "Usage" in result.output
