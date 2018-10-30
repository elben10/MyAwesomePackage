from setuptools import find_packages, setup

setup(
    author="Firstname1 Lastname1, Firstname2 Lastname2",
    name="MyAwesomePackage",
    entry_points={
        'console_scripts': [
            'MyAwesomePackage=MyAwesomePackage.__main__:main',
        ],
    },
    install_requires=[
        'click'
    ],
    packages=find_packages(),
    version="0.1.0",
    license="MIT"
)