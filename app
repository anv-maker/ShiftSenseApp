import React, { useMemo, useState } from "react";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  AreaChart,
  Area,
} from "recharts";
import {
  Bell,
  CalendarDays,
  Clock3,
  BarChart3,
  Users,
  ShieldAlert,
  Sparkles,
  Search,
  FileText,
  Megaphone,
  ChevronRight,
  Check,
  X,
  Plus,
} from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";

/**
 * ShiftSense — Mobile-first app UI (prototype)
 * Founders: Alex Vartanian, Sarah Lima, Will Kaufmann, Mackenzie Wright
 *
 * Notes:
 * - This is a front-end prototype built as a single React file.
 * - Uses Tailwind classes (no import needed in this environment).
 * - Uses recharts for charts and framer-motion for animations.
 */

// ---------- Theme ----------
const theme = {
  bg: "bg-[#F7F8FA]", // soft white
  card: "bg-white",
  text: "text-slate-800",
  muted: "text-slate-500",
  border: "border-slate-200",
  emerald: "text-emerald-600",
  emeraldBg: "bg-emerald-600",
  emeraldSoft: "bg-emerald-50",
  slateBtn: "bg-slate-900",
};

// ---------- Mock Data ----------
const mock = {
  user: { name: "Sarah", business: "Cafe Nova" },
  kpis: {
    laborPct: 22.6,
    salesToday: 4832,
    onShift: 8,
    overtimeRisk: 71,
  },
  laborVsSales: [
    { t: "9a", sales: 320, labor: 120 },
    { t: "10a", sales: 560, labor: 140 },
    { t: "11a", sales: 880, labor: 180 },
    { t: "12p", sales: 1120, labor: 220 },
    { t: "1p", sales: 980, labor: 240 },
    { t: "2p", sales: 760, labor: 230 },
    { t: "3p", sales: 680, labor: 210 },
    { t: "4p", sales: 720, labor: 200 },
  ],
  alerts: [
    {
      id: "a1",
      type: "Overtime Risk",
      icon: "risk",
      severity: "high",
      title: "2 employees nearing overtime",
      detail: "Maria (37.5h) and Jay (38.2h) within 48h window.",
      action: "Review timecards",
    },
    {
      id: "a2",
      type: "Conflict",
      icon: "conflict",
      severity: "med",
      title: "Double-scheduled shift detected",
      detail: "Will is scheduled at 2 locations, 2–6pm.",
      action: "Resolve conflict",
    },
    {
      id: "a3",
      type: "Compliance",
      icon: "law",
      severity: "low",
      title: "Break policy reminder",
      detail: "2 shifts exceed 6h without a recorded break.",
      action: "Audit breaks",
    },
  ],
  schedule: {
    weekLabel: "Feb 9–15",
    days: [
      {
        day: "Mon",
        date: "2/9",
        shifts: [
          { id: "s1", name: "Maria", role: "Barista", time: "8a–2p", badge: "OT" },
          { id: "s2", name: "Jay", role: "Cashier", time: "10a–6p", badge: "" },
        ],
      },
      {
        day: "Tue",
        date: "2/10",
        shifts: [
          { id: "s3", name: "Will", role: "Lead", time: "12p–8p", badge: "!" },
          { id: "s4", name: "Nina", role: "Barista", time: "9a–3p", badge: "" },
        ],
      },
      {
        day: "Wed",
        date: "2/11",
        shifts: [
          { id: "s5", name: "Omar", role: "Stock", time: "7a–1p", badge: "" },
          { id: "s6", name: "Kai", role: "Cashier", time: "1p–7p", badge: "" },
        ],
      },
      {
        day: "Thu",
        date: "2/12",
        shifts: [
          { id: "s7", name: "Mackenzie", role: "Mgr", time: "9a–5p", badge: "" },
        ],
      },
      {
        day: "Fri",
        date: "2/13",
        shifts: [
          { id: "s8", name: "Alex", role: "Ops", time: "10a–6p", badge: "" },
          { id: "s9", name: "Sarah", role: "Owner", time: "11a–4p", badge: "" },
        ],
      },
    ],
    suggestion: {
      title: "Smart scheduling suggestion",
      text: "Based on last month’s sales, add 1 staff member 12–3pm (lunch rush).",
    },
  },
  timecards: [
    { id: "t1", name: "Maria", hours: 37.5, overtimeRisk: true, discrepancies: 1 },
    { id: "t2", name: "Jay", hours: 38.2, overtimeRisk: true, discrepancies: 0 },
    { id: "t3", name: "Will", hours: 31.0, overtimeRisk: false, discrepancies: 2 },
    { id: "t4", name: "Nina", hours: 28.5, overtimeRisk: false, discrepancies: 0 },
    { id: "t5", name: "Omar", hours: 25.0, overtimeRisk: false, discrepancies: 0 },
  ],
  insights: {
    breakdown: [
      { day: "Mon", laborPct: 21.8 },
      { day: "Tue", laborPct: 24.1 },
      { day: "Wed", laborPct: 22.6 },
      { day: "Thu", laborPct: 20.9 },
      { day: "Fri", laborPct: 23.4 },
      { day: "Sat", laborPct: 25.2 },
      { day: "Sun", laborPct: 19.7 },
    ],
    note: "You were likely overstaffed Tue 2–5pm (low sales + higher scheduled hours).",
  },
  hub: {
    timeOff: [
      { id: "r1", name: "Nina", dates: "Feb 18–19", reason: "Family", status: "pending" },
      { id: "r2", name: "Omar", dates: "Feb 14", reason: "Appointment", status: "pending" },
    ],
    announcements: [
      { id: "m1", title: "New menu training", body: "10-min quick training before shift this week." },
      { id: "m2", title: "Clock-in reminder", body: "Please clock in via Square before starting work." },
    ],
    docs: [
      { id: "d1", name: "Employee Handbook.pdf" },
      { id: "d2", name: "Opening Checklist.docx" },
      { id: "d3", name: "Safety & Break Policy.pdf" },
    ],
  },
};

// ---------- Helpers ----------
function money(n) {
  try {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
      maximumFractionDigits: 0,
    }).format(n);
  } catch {
    return `$${n}`;
  }
}

function clsx(...parts) {
  return parts.filter(Boolean).join(" ");
}

function Badge({ label, tone = "slate" }) {
  const tones = {
    emerald: "bg-emerald-50 text-emerald-700 border-emerald-200",
    slate: "bg-slate-50 text-slate-700 border-slate-200",
    red: "bg-red-50 text-red-700 border-red-200",
    amber: "bg-amber-50 text-amber-800 border-amber-200",
  };
  return (
    <span
      className={clsx(
        "inline-flex items-center rounded-full border px-2 py-0.5 text-xs font-medium",
        tones[tone] || tones.slate
      )}
    >
      {label}
    </span>
  );
}

function IconPill({ icon: Icon, label }) {
  return (
    <div className="inline-flex items-center gap-2 rounded-full border border-slate-200 bg-white px-3 py-1.5 text-sm text-slate-700 shadow-sm">
      <Icon className="h-4 w-4 text-emerald-600" />
      <span className="font-medium">{label}</span>
    </div>
  );
}

function Card({ children, className }) {
  return (
    <div
      className={clsx(
        "rounded-2xl border border-slate-200 bg-white shadow-sm",
        className
      )}
    >
      {children}
    </div>
  );
}

function SectionTitle({ title, right }) {
  return (
    <div className="flex items-center justify-between px-4 pb-2 pt-3">
      <h3 className="text-sm font-semibold text-slate-800">{title}</h3>
      {right}
    </div>
  );
}

function Divider() {
  return <div className="h-px bg-slate-100" />;
}

function AlertIcon({ kind }) {
  if (kind === "risk") return <Clock3 className="h-5 w-5 text-amber-600" />;
  if (kind === "conflict") return <ShieldAlert className="h-5 w-5 text-red-600" />;
  return <ShieldAlert className="h-5 w-5 text-slate-700" />;
}

function BottomNav({ active, onChange }) {
  const items = [
    { key: "dashboard", label: "Dashboard", icon: BarChart3 },
    { key: "schedule", label: "Schedule", icon: CalendarDays },
    { key: "timecards", label: "Timecards", icon: Clock3 },
    { key: "insights", label: "Insights", icon: Sparkles },
    { key: "team", label: "Team", icon: Users },
  ];

  return (
    <div className="sticky bottom-0 z-20 w-full border-t border-slate-200 bg-white/90 backdrop-blur">
      <div className="mx-auto grid max-w-md grid-cols-5 px-2 py-2">
        {items.map(({ key, label, icon: Icon }) => {
          const isActive = active === key;
          return (
            <button
              key={key}
              onClick={() => onChange(key)}
              className={clsx(
                "flex flex-col items-center justify-center gap-1 rounded-xl px-2 py-1.5 text-xs",
                isActive
                  ? "text-emerald-700"
                  : "text-slate-600 hover:text-slate-800"
              )}
              aria-label={label}
            >
              <Icon className={clsx("h-5 w-5", isActive && "text-emerald-600")} />
              <span className={clsx("font-medium", isActive ? "" : "")}>{label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

function TopBar({ title, onOpenNotifications }) {
  return (
    <div className="sticky top-0 z-20 w-full bg-[#F7F8FA]/90 backdrop-blur">
      <div className="mx-auto flex max-w-md items-center justify-between px-4 pb-3 pt-4">
        <div className="flex items-center gap-2">
          <div className="grid h-9 w-9 place-items-center rounded-2xl bg-emerald-600 text-white shadow-sm">
            <span className="text-sm font-bold">SS</span>
          </div>
          <div>
            <div className="text-[11px] font-medium text-slate-500">ShiftSense</div>
            <div className="text-base font-semibold text-slate-900 leading-tight">{title}</div>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button className="rounded-xl border border-slate-200 bg-white p-2 shadow-sm" aria-label="Search">
            <Search className="h-4 w-4 text-slate-700" />
          </button>
          <button
            onClick={onOpenNotifications}
            className="relative rounded-xl border border-slate-200 bg-white p-2 shadow-sm"
            aria-label="Notifications"
          >
            <Bell className="h-4 w-4 text-slate-700" />
            <span className="absolute -right-0.5 -top-0.5 h-2.5 w-2.5 rounded-full bg-emerald-600" />
          </button>
          <div className="h-9 w-9 rounded-full bg-slate-900/10 ring-1 ring-slate-200" />
        </div>
      </div>
    </div>
  );
}

function Sheet({ open, title, children, onClose }) {
  return (
    <AnimatePresence>
      {open && (
        <>
          <motion.div
            className="fixed inset-0 z-30 bg-black/40"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
          />
          <motion.div
            className="fixed bottom-0 left-0 right-0 z-40 mx-auto w-full max-w-md rounded-t-3xl border border-slate-200 bg-white shadow-2xl"
            initial={{ y: 40, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: 40, opacity: 0 }}
            transition={{ type: "spring", stiffness: 300, damping: 28 }}
          >
            <div className="flex items-center justify-between px-4 pb-2 pt-4">
              <div>
                <div className="text-xs font-medium text-slate-500">Notifications</div>
                <div className="text-base font-semibold text-slate-900">{title}</div>
              </div>
              <button
                onClick={onClose}
                className="rounded-xl border border-slate-200 bg-white p-2"
                aria-label="Close"
              >
                <X className="h-4 w-4 text-slate-700" />
              </button>
            </div>
            <Divider />
            <div className="max-h-[70vh] overflow-auto">{children}</div>
            <div className="h-5" />
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}

// ---------- Screens ----------
function DashboardScreen({ onPrimaryAction }) {
  const { user, kpis, laborVsSales, alerts } = mock;

  return (
    <div className="mx-auto w-full max-w-md px-4 pb-28">
      <div className="mb-3">
        <div className="text-sm font-medium text-slate-600">Good morning, {user.name} 👋</div>
        <div className="text-xs text-slate-500">{user.business} • Connected to Square</div>
      </div>

      <div className="grid grid-cols-2 gap-3">
        <KpiCard label="Labor Cost" value={`${kpis.laborPct}%`} hint="Target < 25%" />
        <KpiCard label="Sales Today" value={money(kpis.salesToday)} hint="Live" />
        <KpiCard label="On Shift" value={`${kpis.onShift}`} hint="Clocked in" />
        <KpiCard
          label="OT Risk"
          value={`${kpis.overtimeRisk}`}
          hint="Risk score"
          tone={kpis.overtimeRisk >= 70 ? "amber" : "emerald"}
        />
      </div>

      <div className="mt-4">
        <Card>
          <SectionTitle
            title="Labor vs Sales"
            right={<Badge label="Live" tone="emerald" />}
          />
          <div className="h-44 px-2 pb-3">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={laborVsSales} margin={{ top: 10, right: 12, left: -18, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="t" tick={{ fontSize: 11 }} />
                <YAxis tick={{ fontSize: 11 }} />
                <Tooltip />
                <Line type="monotone" dataKey="sales" strokeWidth={2.5} dot={false} />
                <Line type="monotone" dataKey="labor" strokeWidth={2.5} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </div>
          <Divider />
          <div className="flex items-center justify-between px-4 py-3">
            <div className="text-xs text-slate-500">
              Protect margins by matching staffing to demand.
            </div>
            <button
              onClick={() => onPrimaryAction("insights")}
              className="inline-flex items-center gap-1 text-sm font-semibold text-emerald-700"
            >
              Details <ChevronRight className="h-4 w-4" />
            </button>
          </div>
        </Card>
      </div>

      <div className="mt-4">
        <Card>
          <SectionTitle title="Priority Alerts" right={<Badge label={`${alerts.length}`} tone="slate" />} />
          <Divider />
          <div className="divide-y divide-slate-100">
            {alerts.slice(0, 3).map((a) => (
              <div key={a.id} className="flex items-start gap-3 px-4 py-3">
                <div className="mt-0.5 rounded-xl bg-slate-50 p-2">
                  <AlertIcon kind={a.icon} />
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between gap-2">
                    <div className="text-sm font-semibold text-slate-900">{a.title}</div>
                    <Badge
                      label={a.severity.toUpperCase()}
                      tone={a.severity === "high" ? "red" : a.severity === "med" ? "amber" : "slate"}
                    />
                  </div>
                  <div className="mt-0.5 text-xs text-slate-500">{a.detail}</div>
                  <button
                    className="mt-2 inline-flex items-center gap-1 text-sm font-semibold text-emerald-700"
                    onClick={() => onPrimaryAction(a.type === "Overtime Risk" ? "timecards" : "schedule")}
                  >
                    {a.action} <ChevronRight className="h-4 w-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </Card>
      </div>

      <div className="mt-4 grid grid-cols-2 gap-3">
        <QuickAction
          icon={CalendarDays}
          title="Create schedule"
          subtitle="Smart suggestions"
          onClick={() => onPrimaryAction("schedule")}
        />
        <QuickAction
          icon={Clock3}
          title="Audit timecards"
          subtitle="Auto-check hours"
          onClick={() => onPrimaryAction("timecards")}
        />
      </div>

      <div className="mt-4">
        <Card className="overflow-hidden">
          <div className="bg-emerald-600 px-4 py-3 text-white">
            <div className="text-xs font-medium text-white/80">The Intelligent Manager’s Companion</div>
            <div className="text-sm font-semibold">Turn Square data into an actionable roadmap.</div>
          </div>
          <div className="px-4 py-3">
            <div className="flex flex-wrap gap-2">
              <IconPill icon={Sparkles} label="AI Scheduling" />
              <IconPill icon={ShieldAlert} label="Conflict Detection" />
              <IconPill icon={FileText} label="Team Hub" />
            </div>
            <div className="mt-3 text-xs text-slate-500">
              Auto-optimize timesheets, prevent overtime, and protect margins with real-time labor insights.
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
}

function KpiCard({ label, value, hint, tone = "emerald" }) {
  const toneMap = {
    emerald: "text-emerald-700",
    amber: "text-amber-700",
    red: "text-red-700",
  };
  return (
    <Card className="p-4">
      <div className="text-xs font-medium text-slate-500">{label}</div>
      <div className={clsx("mt-1 text-2xl font-semibold", toneMap[tone] || toneMap.emerald)}>
        {value}
      </div>
      <div className="mt-1 text-[11px] text-slate-500">{hint}</div>
    </Card>
  );
}

function QuickAction({ icon: Icon, title, subtitle, onClick }) {
  return (
    <button onClick={onClick} className="text-left">
      <Card className="p-4 hover:shadow-md transition-shadow">
        <div className="flex items-start justify-between">
          <div>
            <div className="text-sm font-semibold text-slate-900">{title}</div>
            <div className="text-xs text-slate-500">{subtitle}</div>
          </div>
          <div className="rounded-xl bg-emerald-50 p-2">
            <Icon className="h-5 w-5 text-emerald-700" />
          </div>
        </div>
      </Card>
    </button>
  );
}

function ScheduleScreen() {
  const { schedule } = mock;
  const [selectedDay, setSelectedDay] = useState(schedule.days[0].day);

  const day = useMemo(
    () => schedule.days.find((d) => d.day === selectedDay) || schedule.days[0],
    [selectedDay, schedule.days]
  );

  return (
    <div className="mx-auto w-full max-w-md px-4 pb-28">
      <Card className="overflow-hidden">
        <div className="px-4 pt-4">
          <div className="flex items-center justify-between">
            <div>
              <div className="text-xs font-medium text-slate-500">Week</div>
              <div className="text-base font-semibold text-slate-900">{schedule.weekLabel}</div>
            </div>
            <button className="inline-flex items-center gap-2 rounded-xl bg-emerald-600 px-3 py-2 text-sm font-semibold text-white shadow-sm">
              <Plus className="h-4 w-4" />
              Add shift
            </button>
          </div>

          <div className="mt-4 grid grid-cols-5 gap-2 pb-4">
            {schedule.days.map((d) => {
              const active = d.day === selectedDay;
              return (
                <button
                  key={d.day}
                  onClick={() => setSelectedDay(d.day)}
                  className={clsx(
                    "rounded-2xl border px-2 py-2 text-center",
                    active
                      ? "border-emerald-200 bg-emerald-50"
                      : "border-slate-200 bg-white"
                  )}
                >
                  <div className={clsx("text-xs font-semibold", active ? "text-emerald-800" : "text-slate-800")}>
                    {d.day}
                  </div>
                  <div className="text-[11px] text-slate-500">{d.date}</div>
                </button>
              );
            })}
          </div>
        </div>

        <Divider />

        <div className="px-4 py-3">
          <div className="flex items-start gap-3 rounded-2xl border border-emerald-200 bg-emerald-50 p-3">
            <div className="rounded-xl bg-white p-2">
              <Sparkles className="h-5 w-5 text-emerald-700" />
            </div>
            <div className="flex-1">
              <div className="text-sm font-semibold text-slate-900">{schedule.suggestion.title}</div>
              <div className="mt-0.5 text-xs text-slate-600">{schedule.suggestion.text}</div>
              <button className="mt-2 inline-flex items-center gap-1 text-sm font-semibold text-emerald-700">
                Apply suggestion <ChevronRight className="h-4 w-4" />
              </button>
            </div>
          </div>
        </div>

        <Divider />

        <SectionTitle
          title={`${day.day} Shifts`}
          right={<Badge label={`${day.shifts.length} shifts`} tone="slate" />}
        />
        <div className="px-4 pb-4">
          <div className="space-y-3">
            {day.shifts.map((s) => (
              <div key={s.id} className="flex items-center justify-between rounded-2xl border border-slate-200 bg-white p-3">
                <div className="min-w-0">
                  <div className="flex items-center gap-2">
                    <div className="text-sm font-semibold text-slate-900 truncate">{s.name}</div>
                    {s.badge === "OT" && <Badge label="OT risk" tone="amber" />}
                    {s.badge === "!" && <Badge label="conflict" tone="red" />}
                  </div>
                  <div className="text-xs text-slate-500">{s.role} • {s.time}</div>
                </div>
                <button className="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm font-semibold text-slate-800">
                  Edit
                </button>
              </div>
            ))}
          </div>

          <div className="mt-4 text-xs text-slate-500">
            Conflict Detection checks double-booking and common labor rules. (Connect rules by location in Settings.)
          </div>
        </div>
      </Card>
    </div>
  );
}

function TimecardsScreen() {
  const [mode, setMode] = useState("regular");
  const [audited, setAudited] = useState(false);

  return (
    <div className="mx-auto w-full max-w-md px-4 pb-28">
      <Card>
        <div className="flex items-center justify-between px-4 pt-4">
          <div>
            <div className="text-xs font-medium text-slate-500">Timesheets</div>
            <div className="text-base font-semibold text-slate-900">Timecards & Overtime</div>
          </div>
          <button
            onClick={() => setAudited(true)}
            className="inline-flex items-center gap-2 rounded-xl bg-emerald-600 px-3 py-2 text-sm font-semibold text-white shadow-sm"
          >
            <Check className="h-4 w-4" />
            Auto-check
          </button>
        </div>

        <div className="px-4 pb-3 pt-3">
          <div className="inline-flex rounded-2xl border border-slate-200 bg-slate-50 p-1">
            {[
              { key: "regular", label: "Regular" },
              { key: "overtime", label: "Overtime" },
              { key: "discrepancies", label: "Discrepancies" },
            ].map((t) => {
              const active = mode === t.key;
              return (
                <button
                  key={t.key}
                  onClick={() => setMode(t.key)}
                  className={clsx(
                    "rounded-2xl px-3 py-2 text-xs font-semibold",
                    active ? "bg-white shadow-sm text-slate-900" : "text-slate-600"
                  )}
                >
                  {t.label}
                </button>
              );
            })}
          </div>

          {audited && (
            <div className="mt-3 rounded-2xl border border-emerald-200 bg-emerald-50 p-3 text-sm text-slate-800">
              <div className="font-semibold">Audit complete</div>
              <div className="mt-0.5 text-xs text-slate-600">
                Found 3 potential issues: 2 overtime risks, 1 missing break.
              </div>
            </div>
          )}
        </div>

        <Divider />

        <div className="divide-y divide-slate-100">
          {mock.timecards.map((e) => {
            const show =
              mode === "regular" ||
              (mode === "overtime" && e.overtimeRisk) ||
              (mode === "discrepancies" && e.discrepancies > 0);
            if (!show) return null;

            return (
              <div key={e.id} className="flex items-center gap-3 px-4 py-3">
                <div className="h-10 w-10 rounded-2xl bg-slate-900/10 ring-1 ring-slate-200" />
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <div className="text-sm font-semibold text-slate-900">{e.name}</div>
                    <div className="text-sm font-semibold text-slate-900">{e.hours.toFixed(1)}h</div>
                  </div>
                  <div className="mt-0.5 flex items-center gap-2">
                    {e.overtimeRisk && <Badge label="OT risk" tone="amber" />}
                    {e.discrepancies > 0 && (
                      <Badge label={`${e.discrepancies} discrepancy`} tone="red" />
                    )}
                    {!e.overtimeRisk && e.discrepancies === 0 && (
                      <span className="text-xs text-slate-500">No issues detected</span>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        <Divider />
        <div className="px-4 py-3 text-xs text-slate-500">
          Direct Square sync via <span className="font-semibold">Square Labor API</span> and permissions via <span className="font-semibold">Square Team API</span>.
        </div>
      </Card>
    </div>
  );
}

function InsightsScreen() {
  const { laborVsSales } = mock;
  return (
    <div className="mx-auto w-full max-w-md px-4 pb-28">
      <Card>
        <SectionTitle title="Real-Time Labor Insights" right={<Badge label="Bird’s-eye" tone="emerald" />} />
        <div className="px-4 pb-3 text-xs text-slate-500">
          Compare live sales to labor cost signals to protect your margins.
        </div>
        <div className="h-52 px-2 pb-4">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={laborVsSales} margin={{ top: 10, right: 12, left: -18, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="t" tick={{ fontSize: 11 }} />
              <YAxis tick={{ fontSize: 11 }} />
              <Tooltip />
              <Area type="monotone" dataKey="sales" fillOpacity={0.25} strokeWidth={2.5} />
              <Area type="monotone" dataKey="labor" fillOpacity={0.25} strokeWidth={2.5} />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        <Divider />

        <div className="px-4 py-4">
          <div className="rounded-2xl border border-slate-200 bg-slate-50 p-3">
            <div className="text-sm font-semibold text-slate-900">Insight</div>
            <div className="mt-0.5 text-xs text-slate-600">{mock.insights.note}</div>
          </div>

          <div className="mt-4 grid grid-cols-2 gap-3">
            <MetricTile title="Overstaff risk" value="Moderate" />
            <MetricTile title="Peak hour" value="12–2pm" />
            <MetricTile title="Labor target" value="< 25%" />
            <MetricTile title="Trend" value="Improving" />
          </div>
        </div>
      </Card>
    </div>
  );
}

function MetricTile({ title, value }) {
  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-3 shadow-sm">
      <div className="text-xs font-medium text-slate-500">{title}</div>
      <div className="mt-1 text-sm font-semibold text-slate-900">{value}</div>
    </div>
  );
}

function TeamHubScreen() {
  const [tab, setTab] = useState("timeoff");
  const [requests, setRequests] = useState(mock.hub.timeOff);

  function updateStatus(id, status) {
    setRequests((prev) => prev.map((r) => (r.id === id ? { ...r, status } : r)));
  }

  return (
    <div className="mx-auto w-full max-w-md px-4 pb-28">
      <Card>
        <div className="px-4 pt-4">
          <div className="text-xs font-medium text-slate-500">Employee Hub</div>
          <div className="text-base font-semibold text-slate-900">Team Hub</div>

          <div className="mt-3 inline-flex rounded-2xl border border-slate-200 bg-slate-50 p-1">
            {[
              { key: "timeoff", label: "Time off" },
              { key: "announcements", label: "Updates" },
              { key: "docs", label: "Docs" },
            ].map((t) => {
              const active = tab === t.key;
              return (
                <button
                  key={t.key}
                  onClick={() => setTab(t.key)}
                  className={clsx(
                    "rounded-2xl px-3 py-2 text-xs font-semibold",
                    active ? "bg-white shadow-sm text-slate-900" : "text-slate-600"
                  )}
                >
                  {t.label}
                </button>
              );
            })}
          </div>
        </div>

        <div className="mt-3">
          <Divider />
        </div>

        <div className="px-4 py-4">
          {tab === "timeoff" && (
            <div className="space-y-3">
              {requests.map((r) => (
                <div key={r.id} className="rounded-2xl border border-slate-200 bg-white p-3">
                  <div className="flex items-start justify-between gap-2">
                    <div>
                      <div className="text-sm font-semibold text-slate-900">{r.name}</div>
                      <div className="text-xs text-slate-500">{r.dates} • {r.reason}</div>
                    </div>
                    <Badge
                      label={r.status.toUpperCase()}
                      tone={r.status === "pending" ? "slate" : r.status === "approved" ? "emerald" : "red"}
                    />
                  </div>

                  {r.status === "pending" && (
                    <div className="mt-3 flex gap-2">
                      <button
                        onClick={() => updateStatus(r.id, "approved")}
                        className="flex-1 rounded-xl bg-emerald-600 px-3 py-2 text-sm font-semibold text-white"
                      >
                        Approve
                      </button>
                      <button
                        onClick={() => updateStatus(r.id, "denied")}
                        className="flex-1 rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm font-semibold text-slate-900"
                      >
                        Deny
                      </button>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}

          {tab === "announcements" && (
            <div className="space-y-3">
              {mock.hub.announcements.map((m) => (
                <div key={m.id} className="rounded-2xl border border-slate-200 bg-white p-3">
                  <div className="flex items-center gap-2">
                    <div className="rounded-xl bg-emerald-50 p-2">
                      <Megaphone className="h-5 w-5 text-emerald-700" />
                    </div>
                    <div className="text-sm font-semibold text-slate-900">{m.title}</div>
                  </div>
                  <div className="mt-2 text-xs text-slate-600">{m.body}</div>
                </div>
              ))}
            </div>
          )}

          {tab === "docs" && (
            <div className="space-y-2">
              {mock.hub.docs.map((d) => (
                <button
                  key={d.id}
                  className="flex w-full items-center justify-between rounded-2xl border border-slate-200 bg-white p-3 text-left"
                >
                  <div className="flex items-center gap-3">
                    <div className="rounded-xl bg-slate-50 p-2">
                      <FileText className="h-5 w-5 text-slate-700" />
                    </div>
                    <div>
                      <div className="text-sm font-semibold text-slate-900">{d.name}</div>
                      <div className="text-xs text-slate-500">Team document</div>
                    </div>
                  </div>
                  <ChevronRight className="h-4 w-4 text-slate-500" />
                </button>
              ))}
            </div>
          )}
        </div>
      </Card>

      <div className="mt-4">
        <Card className="p-4">
          <div className="text-sm font-semibold text-slate-900">About ShiftSense</div>
          <div className="mt-1 text-xs text-slate-600">
            ShiftSense transforms Square labor data into smarter schedules, cleaner timecards, and real-time margin protection.
          </div>
          <div className="mt-3 flex flex-wrap gap-2">
            <Badge label="Square Labor API" tone="slate" />
            <Badge label="Square Team API" tone="slate" />
            <Badge label="Mobile-first" tone="emerald" />
          </div>
          <div className="mt-3 text-[11px] text-slate-500">
            Founders: Alex Vartanian • Sarah Lima • Will Kaufmann • Mackenzie Wright
          </div>
        </Card>
      </div>
    </div>
  );
}

function NotificationsPanel({ onJump }) {
  return (
    <div className="px-4 py-3">
      <div className="space-y-2">
        {mock.alerts.map((a) => (
          <button
            key={a.id}
            className="w-full rounded-2xl border border-slate-200 bg-white p-3 text-left"
            onClick={() => onJump(a.type === "Overtime Risk" ? "timecards" : "schedule")}
          >
            <div className="flex items-start gap-3">
              <div className="mt-0.5 rounded-xl bg-slate-50 p-2">
                <AlertIcon kind={a.icon} />
              </div>
              <div className="flex-1">
                <div className="flex items-center justify-between gap-2">
                  <div className="text-sm font-semibold text-slate-900">{a.title}</div>
                  <Badge
                    label={a.severity.toUpperCase()}
                    tone={a.severity === "high" ? "red" : a.severity === "med" ? "amber" : "slate"}
                  />
                </div>
                <div className="mt-0.5 text-xs text-slate-500">{a.detail}</div>
              </div>
            </div>
          </button>
        ))}
      </div>

      <div className="mt-4 rounded-2xl border border-slate-200 bg-slate-50 p-3 text-xs text-slate-600">
        Tip: Configure local labor rules in Settings to enable stricter compliance alerts.
      </div>
    </div>
  );
}

// ---------- Root App ----------
export default function ShiftSenseApp() {
  const [tab, setTab] = useState("dashboard");
  const [notifOpen, setNotifOpen] = useState(false);

  const title =
    tab === "dashboard"
      ? "Dashboard"
      : tab === "schedule"
      ? "Scheduling"
      : tab === "timecards"
      ? "Timecards"
      : tab === "insights"
      ? "Insights"
      : "Team Hub";

  return (
    <div className={clsx("min-h-screen", theme.bg)}>
      {/* Mobile device frame */}
      <div className="mx-auto min-h-screen w-full max-w-md">
        <TopBar title={title} onOpenNotifications={() => setNotifOpen(true)} />

        <motion.div
          key={tab}
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.2 }}
        >
          {tab === "dashboard" && (
            <DashboardScreen onPrimaryAction={(next) => setTab(next)} />
          )}
          {tab === "schedule" && <ScheduleScreen />}
          {tab === "timecards" && <TimecardsScreen />}
          {tab === "insights" && <InsightsScreen />}
          {tab === "team" && <TeamHubScreen />}
        </motion.div>

        <BottomNav active={tab} onChange={setTab} />

        <Sheet
          open={notifOpen}
          title="Alerts & Notifications"
          onClose={() => setNotifOpen(false)}
        >
          <NotificationsPanel
            onJump={(next) => {
              setTab(next);
              setNotifOpen(false);
            }}
          />
        </Sheet>
      </div>
    </div>
  );
}
