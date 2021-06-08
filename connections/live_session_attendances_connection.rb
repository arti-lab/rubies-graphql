class Connections::LiveSessionAttendancesConnection < Connections::BaseConnectionType
  edge_type(Edges::AttendancesEdge, node_type: Types::AttendanceType)
end
