"""This module provides a function to get a Cassandra session to the backend_llm keyspace.
The function gets a cluster and establishes a session to the backend_llm keyspace. If the
keyspace does not exist, it is created with a replication factor of 1.
"""

from cassandra.cluster import Cluster  # pylint: disable=no-name-in-module
from cassandra.policies import DCAwareRoundRobinPolicy  # pylint: disable=no-name-in-module
from cassandra.cqlengine.connection import (
    register_connection,
    set_default_connection,
)  # pylint: disable=no-name-in-module

KEYSPACE = "backend_llm"


def get_session() -> Cluster:
    """Get a Cassandra session to the backend_llm keyspace.

    If the keyspace does not exist, it is created with a replication factor of 1.

    Returns:
        A Cassandra session to the backend_llm keyspace.
    """
    cluster = Cluster(
        ["cassandra"],
        port=9042,
        load_balancing_policy=DCAwareRoundRobinPolicy(local_dc="datacenter1"),
        protocol_version=4,
    )
    session = cluster.connect()
    session.execute(
        f"CREATE KEYSPACE IF NOT EXISTS {KEYSPACE} "
        "WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor' : 1}"
    )
    register_connection(str(session), session=session)
    set_default_connection(str(session))
    return session

def get_keyspace() -> str:
    """
    A function to get the cluster and establish a session to a specific keyspace.
    """
    return KEYSPACE