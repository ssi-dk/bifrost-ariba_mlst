#!/usr/bin/env python3
"""
Launcher file for accessing dockerfile commands
"""
import argparse
import json
import subprocess
import os
import sys
import traceback
from bifrostlib import datahandling

COMPONENT: dict = datahandling.load_yaml(os.path.join(os.path.dirname(__file__), 'config.yaml'))

class types():
    def file(path):
        if os.path.isfile(path):
            return os.path.abspath(path)
        else:
            raise argparse.ArgumentTypeError(f"{path} #Not a valid path")
    def directory(path):
        if os.path.isdir(path):
            return os.path.abspath(path)
        else:
            raise argparse.ArgumentTypeError(f"{path} #Not a valid path")

def parser(args):
    """
    Arg parsing via argparse
    """
    description: str = (
        f"-Description------------------------------------\n"
        f"{COMPONENT['details']['description']}"
        f"------------------------------------------------\n"
        f"\n"
        f"-Environmental Variables/Defaults---------------\n"
        f"BIFROST_CONFIG_DIR: {os.environ.get('BIFROST_CONFIG_DIR','.')}\n"
        f"BIFROST_RUN_DIR: {os.environ.get('BIFROST_RUN_DIR','.')}\n"
        f"BIFROST_DB_KEY: {os.environ.get('BIFROST_DB_KEY')}\n"
        f"------------------------------------------------\n"
        f"\n"
    )
    install_parser = argparse.ArgumentParser(add_help=False)
    install_parser.add_argument(
        '--install',
        action='store_true',
        )
    parser: argparse.ArgumentParser = argparse.ArgumentParser(description=description, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        '--info',
        action='store_true',
        help='Provides basic information on component'
        )
    parser.add_argument(
        '--debug',
        action='store_true',
        help='Show arg values'
        )
    parser.add_argument(
        '-out', '--outdir',
        default=os.environ.get('BIFROST_RUN_DIR',os.getcwd()),
        help='Output directory'
        )
    parser.add_argument(
        '-id', '--sample_id',
        action='store',
        type=str,
        help='Sample ID of sample in bifrost, sample has already been added to the bifrost DB'
        )

    try:
        install_options, extras = install_parser.parse_known_args(args)
        if install_options.install:
            install_component()
            return None
        else:
            run_options = parser.parse_args(extras)
            if run_options.debug is True:
                print(run_options)
            run_program(run_options)
    except:
        sys.exit(0)

def run_program(args: argparse.Namespace):
    if not datahandling.check_db_connection_exists():
        message: str = (
            f"ERROR: Connection to DB not establised.\n"
            f"please ensure env variable BIFROST_DB_KEY is set and set properly\n"
        )
        print(message)
    else:
        print(datahandling.get_connection_info())

    if args.info:
        show_info()
    else:
        run_pipeline(args)


def show_info():
    """
    Shows information about the component
    """
    message: str = (
        f"Component: {COMPONENT['name']}\n"
        f"Version: {COMPONENT['version']}\n"
        f"Details: {json.dumps(COMPONENT['details'], indent=4)}\n"
        f"Requirements: {json.dumps(COMPONENT['requirements'], indent=4)}\n"
        f"Output files: {json.dumps(COMPONENT['db_values_changes']['files'], indent=4)}\n"
    )
    print(message)


def install_component():
    component: list[dict] = datahandling.get_components(component_names=[COMPONENT['name']])
    # if len(component) == 1:
    #     print(f"Component has already been installed")
    if len(component) > 1:
        print(f"Component exists multiple times in DB, please contact an admin to fix this in order to proceed")
    else:
        #HACK: Installs based on your current directory currently. Should be changed to the directory your docker/singularity file is
        #HACK: Removed install check so you can reinstall the component. Should do this in a nicer way
        COMPONENT['install']['path'] = os.path.os.getcwd()
        print(f"Installing with path:{COMPONENT['install']['path']}")
        datahandling.post_component(COMPONENT)
        component: list[dict] = datahandling.get_components(component_names=[COMPONENT['name']])
        if len(component) != 1:
            print(f"Error with installation of {COMPONENT['name']} {len(component)}\n")
            exit()
        print(f"Done installing")


def run_pipeline(args: object):
    """
    Runs sample ID through snakemake pipeline
    """
    if not os.path.isdir(args.outdir):
        os.makedirs(args.outdir)
    os.chdir(args.outdir)

    sample: list[dict] = datahandling.get_samples(sample_ids=[args.sample_id])
    component: list[dict] = datahandling.get_components(component_names=[COMPONENT['name']])
    if len(component) == 0:
        print(f"component not found in DB, installing it:")
        install_component()

    if len(sample) == 0:
        # Invalid sample id
        print(f"sample_id not found in DB")
        pass
    elif len(sample) != 1:
        print(f"Error with sample_id")
    elif len(component) != 1:
        print(f"Error with component_id")
    else:
        print(f"snakemake -s /bifrost_{COMPONENT['display_name']}/bifrost_{COMPONENT['display_name']}/pipeline.smk --config sample_id={str(sample[0]['_id'])} component_id={str(component[0]['_id'])}")
        try:
            process: subprocess.Popen = subprocess.Popen(
                f"snakemake -s /bifrost_{COMPONENT['display_name']}/bifrost_{COMPONENT['display_name']}/pipeline.smk --config sample_id={str(sample[0]['_id'])} component_id={str(component[0]['_id'])}",
                stdout=sys.stdout,
                stderr=sys.stderr,
                shell=True
            )
            process.communicate()
        except:
            print(traceback.format_exc())

def run():
    args: argparse.Namespace = parser(sys.argv[1:])

if __name__ == '__main__':
    run()
